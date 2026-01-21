// 使用 luaparse 解析 Lua，使用 wasmoon 在服務端執行 Lua 規則
import luaparse from 'luaparse';

// NOTE: `wasmoon` (emscripten) can break if webpack-bundled inside Next.js route/server bundles.
// Load it lazily via Node `require` at runtime (server-only) to avoid bundler transforms.
type WasmoonModule = typeof import('wasmoon');
let _LuaFactory: WasmoonModule['LuaFactory'] | null = null;

async function getLuaFactoryCtor(): Promise<WasmoonModule['LuaFactory']> {
  if (_LuaFactory) return _LuaFactory;
  if (typeof window !== 'undefined') {
    throw new Error('wasmoon can only be initialized on the server (Node runtime)');
  }
  // Use dynamic import to keep it server-only while remaining compatible with ESM.
  const mod = (await import('wasmoon')) as WasmoonModule;
  _LuaFactory = mod.LuaFactory;
  return _LuaFactory;
}

export interface LuaRegister {
  Name: string;
  Group?: string;
  MemI_B0?: { Addr: number; MSB: number; LSB: number };
  MemI_B1?: { Addr: number; MSB: number; LSB: number };
  DACValueExpr?: string;
  Unit?: string;
  DAC?: number;
  ReadOnly?: boolean;
  IsTextBlock?: boolean;
}

export interface LuaRegisterTable {
  Name: string;
  DeviceAddress: number[];
  FrontDoorRegisters: { [key: string]: LuaRegister };
  BackDoorRegisters?: { [key: string]: LuaRegister };
  NeedShowMemIndex?: number[];
  ChecksumMemIndexCollect?: { [key: string]: number[] };
}

export interface LuaProduct {
  Name: string;
  Type: string;
  Application: string;
  RegisterTable: LuaRegisterTable[];
  Rules?: { [key: string]: string }; // 規則名稱 -> 規則函數源代碼
}

/**
 * 遞歸遍歷 AST 節點
 */
function traverseNode(node: any, callback: (node: any) => void): void {
  if (!node || typeof node !== 'object') return;

  callback(node);

  for (const key in node) {
    if (key === 'type' || key === 'loc' || key === 'range') continue;
    const value = node[key];
    if (Array.isArray(value)) {
      for (const item of value) {
        traverseNode(item, callback);
      }
    } else if (value && typeof value === 'object') {
      traverseNode(value, callback);
    }
  }
}

/**
 * 查找特定類型的節點
 */
function findNodes(node: any, nodeType: string): any[] {
  const results: any[] = [];

  traverseNode(node, (n) => {
    if (n.type === nodeType) {
      results.push(n);
    }
  });

  return results;
}

/**
 * 提取字符串值
 */
function extractString(node: any): string {
  if (!node) return '';
  if (node.type === 'StringLiteral' && node.raw) {
    return node.raw.replace(/^['"]|['"]$/g, '');
  }
  if (node.type === 'Identifier') {
    return node.name || '';
  }
  return '';
}

/**
 * 提取數值（支援十六進制和十進制）
 */
function extractNumber(node: any): number | undefined {
  if (!node) return undefined;
  if (node.type === 'NumericLiteral') {
    const raw = node.raw;
    if (raw) {
      if (raw.startsWith('0x') || raw.startsWith('0X')) {
        return parseInt(raw, 16);
      }
      return parseInt(raw, 10);
    }
    return node.value;
  }
  return undefined;
}

/**
 * 從 TableConstructorExpression 或 TableCallExpression 獲取實際的表
 */
function getTableFromNode(node: any): any {
  if (!node) return null;

  if (node.type === 'TableConstructorExpression') {
    return node;
  }

  if (node.type === 'TableCallExpression') {
    if (node.arguments && node.arguments.type === 'TableConstructorExpression') {
      return node.arguments;
    }

    if (node.base && node.base.type === 'MemberExpression') {
      if (node.base.base && node.base.base.type === 'TableConstructorExpression') {
        return node.base.base;
      }
      if (node.base.index && node.base.index.type === 'TableConstructorExpression') {
        return node.base.index;
      }
    }

    if (node.base && node.base.type === 'TableConstructorExpression') {
      return node.base;
    }
  }

  if (node.type === 'MemberExpression') {
    if (node.base && node.base.type === 'TableConstructorExpression') {
      return node.base;
    }
    if (node.index && node.index.type === 'TableConstructorExpression') {
      return node.index;
    }
  }

  return null;
}

/**
 * 解析 TableConstructorExpression 中的字段
 */
function parseTableFields(tableNode: any): { [key: string]: any } {
  const result: { [key: string]: any } = {};

  if (!tableNode || !tableNode.fields) {
    return result;
  }

  for (const field of tableNode.fields) {
    // 處理數組元素（沒有明確 key）
    if (!field.key && field.value) {
      const arrayIndex = result._arrayLength !== undefined ? result._arrayLength : 0;
      result._arrayLength = arrayIndex + 1;

      if (field.value.type === 'NumericLiteral') {
        result[arrayIndex] = extractNumber(field.value);
      } else if (field.value.type === 'StringLiteral') {
        result[arrayIndex] = extractString(field.value);
      } else if (field.value.type === 'TableConstructorExpression') {
        result[arrayIndex] = parseTableFields(field.value);
      } else {
        result[arrayIndex] = field.value;
      }
      continue;
    }

    let key: string | undefined;

    if (field.key) {
      if (field.key.type === 'Identifier') {
        key = field.key.name;
      } else if (field.key.type === 'StringLiteral') {
        key = extractString(field.key);
      } else if (field.key.type === 'NumericLiteral') {
        const num = extractNumber(field.key);
        if (num !== undefined) {
          key = String(num);
        }
      }
    }

    if (key !== undefined && field.value) {
      if (field.value.type === 'TableConstructorExpression') {
        result[key] = parseTableFields(field.value);
      } else if (field.value.type === 'TableCallExpression') {
        const table = getTableFromNode(field.value);
        if (table) {
          result[key] = parseTableFields(table);
        } else {
          if (field.value.base && field.value.base.type === 'MemberExpression') {
            const base = field.value.base;
            if (base.base && base.base.type === 'TableConstructorExpression') {
              result[key] = parseTableFields(base.base);
            } else if (base.index && base.index.type === 'TableConstructorExpression') {
              result[key] = parseTableFields(base.index);
            } else {
              result[key] = field.value;
            }
          } else {
            result[key] = field.value;
          }
        }
      } else if (field.value.type === 'CallExpression') {
        const table = getTableFromNode(field.value);
        if (table) {
          result[key] = parseTableFields(table);
        } else {
          result[key] = field.value;
        }
      } else if (field.value.type === 'NumericLiteral') {
        result[key] = extractNumber(field.value);
      } else if (field.value.type === 'StringLiteral') {
        result[key] = extractString(field.value);
      } else if (field.value.type === 'TrueLiteral' || field.value.type === 'FalseLiteral') {
        result[key] = field.value.type === 'TrueLiteral';
      } else if (field.value.type === 'FunctionExpression' || field.value.type === 'FunctionDeclaration') {
        result[key] = field.value;
      } else {
        const table = getTableFromNode(field.value);
        if (table) {
          result[key] = parseTableFields(table);
        } else {
          result[key] = field.value;
        }
      }
    }
  }

  // 如果檢測到數組結構，轉換為真正的數組
  if (result._arrayLength !== undefined && result._arrayLength > 0) {
    const arr: any[] = [];
    for (let i = 0; i < result._arrayLength; i++) {
      arr.push(result[i]);
    }
    delete result._arrayLength;
    return arr;
  }

  delete result._arrayLength;
  return result;
}

/**
 * 解析 Register
 */
function parseRegister(regNode: any): LuaRegister {
  const reg: LuaRegister = {
    Name: ''
  };

  const tableNode = getTableFromNode(regNode);
  if (!tableNode || !tableNode.fields) {
    return reg;
  }

  const fields = parseTableFields(tableNode);

  if (fields.Name !== undefined) reg.Name = fields.Name;
  if (fields.Group !== undefined) reg.Group = fields.Group;
  if (fields.Unit !== undefined) reg.Unit = fields.Unit;
  if (fields.DAC !== undefined) reg.DAC = fields.DAC;
  if (fields.DACValueExpr !== undefined) reg.DACValueExpr = fields.DACValueExpr;
  if (fields.ReadOnly !== undefined) reg.ReadOnly = fields.ReadOnly;
  if (fields.IsTextBlock !== undefined) reg.IsTextBlock = fields.IsTextBlock;

  if (fields.MemI_B0 && typeof fields.MemI_B0 === 'object') {
    reg.MemI_B0 = {
      Addr: fields.MemI_B0.Addr || 0,
      MSB: fields.MemI_B0.MSB || 0,
      LSB: fields.MemI_B0.LSB || 0
    };
  }

  if (fields.MemI_B1 && typeof fields.MemI_B1 === 'object') {
    reg.MemI_B1 = {
      Addr: fields.MemI_B1.Addr || 0,
      MSB: fields.MemI_B1.MSB || 0,
      LSB: fields.MemI_B1.LSB || 0
    };
  }

  return reg;
}

/**
 * 解析 RegisterTable
 */
function parseRegisterTable(rtNode: any): LuaRegisterTable {
  const table: LuaRegisterTable = {
    Name: 'Default',
    DeviceAddress: [],
    FrontDoorRegisters: {}
  };

  // 如果是純 JS 對象（已經被 parseTableFields 解析過的），直接使用
  if (rtNode && typeof rtNode === 'object' && !rtNode.type) {
    const fields = rtNode as any;
    table.Name = fields.Name || 'Default';
    table.DeviceAddress = fields.DeviceAddress || [];
    table.NeedShowMemIndex = fields.NeedShowMemIndex;

    if (fields.FrontDoorRegisters && typeof fields.FrontDoorRegisters === 'object') {
      for (const [regName, regData] of Object.entries(fields.FrontDoorRegisters)) {
        if (regData && typeof regData === 'object') {
          const regDataAny = regData as any;
          const reg: LuaRegister = {
            Name: regDataAny.Name || regName
          };

          if (regDataAny.Group !== undefined) reg.Group = regDataAny.Group;
          if (regDataAny.Unit !== undefined) reg.Unit = regDataAny.Unit;
          if (regDataAny.DAC !== undefined) reg.DAC = regDataAny.DAC;
          if (regDataAny.DACValueExpr !== undefined) reg.DACValueExpr = regDataAny.DACValueExpr;
          if (regDataAny.ReadOnly !== undefined) reg.ReadOnly = regDataAny.ReadOnly;
          if (regDataAny.IsTextBlock !== undefined) reg.IsTextBlock = regDataAny.IsTextBlock;

          if (regDataAny.MemI_B0 && typeof regDataAny.MemI_B0 === 'object') {
            reg.MemI_B0 = {
              Addr: regDataAny.MemI_B0.Addr || 0,
              MSB: regDataAny.MemI_B0.MSB || 0,
              LSB: regDataAny.MemI_B0.LSB || 0
            };
          }

          if (regDataAny.MemI_B1 && typeof regDataAny.MemI_B1 === 'object') {
            reg.MemI_B1 = {
              Addr: regDataAny.MemI_B1.Addr || 0,
              MSB: regDataAny.MemI_B1.MSB || 0,
              LSB: regDataAny.MemI_B1.LSB || 0
            };
          }

          table.FrontDoorRegisters[regName] = reg;
        }
      }
    }

    return table;
  }

  // 如果是 TableCallExpression
  if (rtNode && rtNode.type === 'TableCallExpression') {
    const arg = rtNode.arguments;
    if (arg && arg.type === 'TableConstructorExpression') {
      return parseRegisterTable(arg);
    }
  }

  const tableNode = getTableFromNode(rtNode);
  if (!tableNode || !tableNode.fields) {
    if (rtNode && rtNode.fields) {
      const fields = parseTableFields(rtNode);
      table.Name = fields.Name || 'Default';
      table.DeviceAddress = fields.DeviceAddress || [];
    }
    return table;
  }

  const fields = parseTableFields(tableNode);

  if (fields.Name !== undefined) table.Name = fields.Name;
  if (fields.DeviceAddress) table.DeviceAddress = fields.DeviceAddress;

  if (fields.FrontDoorRegisters && typeof fields.FrontDoorRegisters === 'object') {
    for (const [regName, regData] of Object.entries(fields.FrontDoorRegisters)) {
      let parsedRegData = regData;
      if (regData && typeof regData === 'object' && (regData as any).type === 'TableCallExpression') {
        const tableNode = getTableFromNode(regData);
        if (tableNode && tableNode.fields) {
          parsedRegData = parseTableFields(tableNode);
        }
      }

      if (parsedRegData && typeof parsedRegData === 'object') {
        const regDataAny = parsedRegData as any;
        const reg: LuaRegister = {
          Name: regDataAny.Name || regName
        };

        if (regDataAny.Group !== undefined) reg.Group = regDataAny.Group;
        if (regDataAny.Unit !== undefined) reg.Unit = regDataAny.Unit;
        if (regDataAny.DAC !== undefined) reg.DAC = regDataAny.DAC;
        if (regDataAny.DACValueExpr !== undefined) reg.DACValueExpr = regDataAny.DACValueExpr;
        if (regDataAny.ReadOnly !== undefined) reg.ReadOnly = regDataAny.ReadOnly;
        if (regDataAny.IsTextBlock !== undefined) reg.IsTextBlock = regDataAny.IsTextBlock;

        if (regDataAny.MemI_B0 && typeof regDataAny.MemI_B0 === 'object') {
          reg.MemI_B0 = {
            Addr: regDataAny.MemI_B0.Addr || 0,
            MSB: regDataAny.MemI_B0.MSB || 0,
            LSB: regDataAny.MemI_B0.LSB || 0
          };
        }

        if (regDataAny.MemI_B1 && typeof regDataAny.MemI_B1 === 'object') {
          reg.MemI_B1 = {
            Addr: regDataAny.MemI_B1.Addr || 0,
            MSB: regDataAny.MemI_B1.MSB || 0,
            LSB: regDataAny.MemI_B1.LSB || 0
          };
        }

        table.FrontDoorRegisters[regName] = reg;
      }
    }
  }

  if (fields.BackDoorRegisters && typeof fields.BackDoorRegisters === 'object') {
    table.BackDoorRegisters = {};
    for (const [regName, regData] of Object.entries(fields.BackDoorRegisters)) {
      if (regData && typeof regData === 'object') {
        table.BackDoorRegisters[regName] = parseRegister(regData as any);
      }
    }
  }

  if (fields.NeedShowMemIndex) table.NeedShowMemIndex = fields.NeedShowMemIndex;

  if (fields.ChecksumMemIndexCollect && typeof fields.ChecksumMemIndexCollect === 'object') {
    table.ChecksumMemIndexCollect = {};
    for (const [groupName, groupData] of Object.entries(fields.ChecksumMemIndexCollect)) {
      if (Array.isArray(groupData)) {
        table.ChecksumMemIndexCollect[groupName] = groupData as number[];
      }
    }
  }

  return table;
}

/**
 * 解析 Product
 */
function parseProduct(productNode: any): LuaProduct {
  const product: LuaProduct = {
    Name: '',
    Type: '',
    Application: '',
    RegisterTable: []
  };

  const tableNode = getTableFromNode(productNode);
  if (!tableNode || !tableNode.fields) {
    return product;
  }

  for (const field of tableNode.fields) {
    if (field.key && field.key.name === 'RegisterTable' && field.value) {
      if (field.value.type === 'TableConstructorExpression') {
        if (field.value.fields && field.value.fields.length > 0) {
          const firstField = field.value.fields[0];

          if (firstField.value && firstField.value.type === 'TableCallExpression') {
            const arg = firstField.value.arguments;
            if (arg && arg.type === 'TableConstructorExpression') {
              const rt = parseRegisterTable(arg);
              product.RegisterTable.push(rt);
            } else if (arg && Array.isArray(arg) && arg.length > 0) {
              const innerArg = arg[0];
              if (innerArg && innerArg.type === 'TableConstructorExpression') {
                const rt = parseRegisterTable(innerArg);
                product.RegisterTable.push(rt);
              }
            }
          } else {
            const rt = parseRegisterTable(field.value);
            product.RegisterTable.push(rt);
          }
        } else {
          const rt = parseRegisterTable(field.value);
          product.RegisterTable.push(rt);
        }
      } else if (field.value.type === 'TableCallExpression') {
        const table = getTableFromNode(field.value);
        if (table) {
          const rt = parseRegisterTable(table);
          product.RegisterTable.push(rt);
        }
      } else if (field.value.type === 'CallExpression') {
        const table = getTableFromNode(field.value);
        if (table) {
          const rt = parseRegisterTable(table);
          product.RegisterTable.push(rt);
        }
      }

      break;
    }
  }

  const fields = parseTableFields(tableNode);

  if (fields.Name !== undefined) product.Name = fields.Name;
  if (fields.Type !== undefined) product.Type = fields.Type;
  if (fields.Application !== undefined) product.Application = fields.Application;

  return product;
}

/**
 * 從 ReturnStatement 或其他節點中提取 Product 表
 */
function extractProductFromReturnStatement(node: any): any {
  if (!node) return null;

  if (node.type === 'ReturnStatement' && node.argument) {
    const arg = node.argument;

    if (arg.type === 'TableCallExpression') {
      return arg;
    }

    if (arg.type === 'CallExpression') {
      return arg;
    }

    if (arg.type === 'TableConstructorExpression') {
      return arg;
    }
  }

  return node;
}

/**
 * 評估規則（服務端使用 wasmoon 執行 Lua）
 */
export async function evaluateRules(
  content: string,
  regValues: { [key: string]: any }
): Promise<{ [key: string]: [string, boolean] }> {
  const results: { [key: string]: [string, boolean] } = {};

  // 只允許在服務端執行
  if (typeof window !== 'undefined') {
    console.warn('[evaluateRules] 僅支援服務端執行，瀏覽器請調用 API');
    return results;
  }

  const LuaFactory = await getLuaFactoryCtor();
  const factory = new LuaFactory();
  const lua = await factory.createEngine();

  // 將 RegValues 注入 Lua 全域
  await lua.global.set('RegValues', regValues);
  await lua.global.set('get_register_value', (name: string) => {
    const v =
      regValues[`${name}_Value`] ??
      regValues[name] ??
      regValues[`${name}_DAC`];
    return v === undefined ? null : v;
  });

  // 注入 DiagramHelper (模擬 WPF 版本的功能)
  await lua.global.set('DiagramHelper', {
    GetNumber: (key: string, regValues: any, defaultValue: number = 0) => {
      if (regValues && typeof regValues === 'object') {
        const value = regValues[key];
        if (value !== undefined && value !== null) {
          const num = Number(value);
          return isNaN(num) ? defaultValue : num;
        }
      }
      return defaultValue;
    },
    GetRegisterDAC: (name: string, regValues: any) => {
      if (regValues && typeof regValues === 'object') {
        const dacKey = `${name}_DAC`;
        const dacValue = regValues[dacKey];
        if (dacValue !== undefined && dacValue !== null) {
          const num = Number(dacValue);
          return isNaN(num) ? 0 : num;
        }
      }
      return 0;
    },
    GetRegisterValue: (name: string, reg: any, regValues: any) => {
      if (regValues && typeof regValues === 'object') {
        // 優先順序：regValues[name] -> regValues[name_Value] -> regValues[name_DAC]
        let value = regValues[name];
        if (value !== undefined && value !== null) {
          return value;
        }

        const valueKey = `${name}_Value`;
        value = regValues[valueKey];
        if (value !== undefined && value !== null) {
          return value;
        }

        const dacKey = `${name}_DAC`;
        const dacValue = regValues[dacKey];
        if (dacValue !== undefined && dacValue !== null) {
          return Number(dacValue);
        }
      }
      return null;
    }
  });

  // 執行原始 Lua 內容
  await lua.doString(content);

  // 在 Lua 端遍歷 rule 表，回傳結果
  const luaResult = await lua.doString(`
    local results = {}
    if type(rule) == 'table' then
      for k, fn in pairs(rule) do
        if type(fn) == 'function' then
          local ok, ret = pcall(fn)
          if ok and type(ret) == 'table' then
            local desc = ret[1] or tostring(k)
            local passed = not not ret[2]
            results[k] = { desc, passed }
          else
            results[k] = { "評估錯誤: " .. tostring(ret), false }
          end
        end
      end
    end
    return results
  `);

  if (luaResult && typeof luaResult === 'object') {
    for (const [k, v] of Object.entries(luaResult as Record<string, any>)) {
      if (Array.isArray(v) && v.length >= 2) {
        results[k] = [String(v[0]), Boolean(v[1])];
      }
    }
  }

  // wasmoon exposes `close()` on the Global thread (sync).
  lua.global.close();
  return results;
}

/**
 * 導出的 extractRules 函數（保持舊接口，返回源代碼）
 * 這個函數在服務端和客戶端都可以使用
 */
export function extractRules(content: string): { [key: string]: string } {
  const rules: { [key: string]: string } = {};

  // 查找 rule = { ... } 區塊
  const ruleStartMatch = content.match(/rule\s*=\s*\{/);
  if (!ruleStartMatch) {
    return rules;
  }

  const ruleStartIdx = ruleStartMatch.index!;
  let depth = 0;
  let ruleEndIdx = -1;

  for (let i = ruleStartIdx; i < content.length; i++) {
    if (content[i] === '{') depth++;
    if (content[i] === '}') {
      depth--;
      if (depth === 0) {
        ruleEndIdx = i + 1;
        break;
      }
    }
  }

  if (ruleEndIdx === -1) {
    return rules;
  }

  const ruleBlock = content.substring(ruleStartIdx, ruleEndIdx);

  try {
    const ast = luaparse.parse(ruleBlock, { lax: true, ranges: true });

    const tableNodes = findNodes(ast, 'TableConstructorExpression');

    if (tableNodes.length > 0) {
      const fields = parseTableFields(tableNodes[0]);

      for (const [ruleName, ruleValue] of Object.entries(fields)) {
        if (ruleValue && typeof ruleValue === 'object') {
          const rv = ruleValue as any;

          if (typeof rv === 'string' && rv.trimStart().startsWith('function')) {
            rules[ruleName] = rv;
            continue;
          }

          if (rv.type === 'FunctionExpression' || rv.type === 'FunctionDeclaration') {
            if (rv.range) {
              const start = rv.range[0];
              const end = rv.range[1];
              const funcBody = ruleBlock.substring(start, end + 1);
              rules[ruleName] = funcBody;
            }
          }
        }
      }
    }
  } catch (err) {
    console.error('[extractRules] Error:', err);
  }

  return rules;
}

/**
 * 主解析函數
 */
export function parseLuaProduct(content: string): LuaProduct {
  let ast: any;
  try {
    ast = luaparse.parse(content, {
      lax: true,
      scope: true,
      locations: true,
      ranges: true
    });
  } catch (err) {
    console.error('Error parsing Lua content:', err);
    return {
      Name: 'Unknown',
      Type: 'Unknown',
      Application: 'General',
      RegisterTable: []
    };
  }

  const funcNodes = findNodes(ast, 'FunctionDeclaration');

  if (funcNodes.length > 0) {
    for (const funcNode of funcNodes) {
      if (funcNode.identifier && funcNode.identifier.name === 'Build') {
        if (funcNode.body && funcNode.body.body) {
          for (const stmt of funcNode.body.body) {
            const productNode = extractProductFromReturnStatement(stmt);
            if (productNode) {
              const product = parseProduct(productNode);
              if (product.RegisterTable.length > 0) {
                product.Rules = extractRules(content);
                console.log('Parsed product from Build():', product.Name, product.Type);
                console.log('RegisterTable count:', product.RegisterTable.length);
                return product;
              }
            }
          }
        }
      }
    }
  }

  const productNodes = findNodes(ast, 'TableConstructorExpression');

  if (productNodes.length === 0) {
    const tableCallNodes = findNodes(ast, 'TableCallExpression');
    if (tableCallNodes.length > 0) {
      const product = parseProduct(tableCallNodes[0]);
      product.Rules = extractRules(content);
      console.log('Parsed product from TableCallExpression:', product.Name, product.Type);
      console.log('RegisterTable count:', product.RegisterTable.length);
      return product;
    }

    return {
      Name: 'Unknown',
      Type: 'Unknown',
      Application: 'General',
      RegisterTable: []
    };
  }

  const product = parseProduct(productNodes[0]);
  product.Rules = extractRules(content);

  console.log('Parsed product:', product.Name, product.Type);
  console.log('RegisterTable count:', product.RegisterTable.length);

  if (product.RegisterTable.length > 0) {
    const rt = product.RegisterTable[0];
    console.log('FrontDoorRegisters count:', Object.keys(rt.FrontDoorRegisters).length);
  }

  return product;
}

/**
 * 解析 Lua 寄存器表（簡化版本）
 */
export function parseLuaRegisterTable(content: string): LuaRegisterTable | null {
  let ast: any;
  try {
    ast = luaparse.parse(content, {
      lax: true,
      scope: true
    });
  } catch (err) {
    console.error('Error parsing Lua content:', err);
    return null;
  }

  const rtNodes = findNodes(ast, 'TableConstructorExpression');

  for (const rtNode of rtNodes) {
    const fields = parseTableFields(rtNode);
    if (fields.Name && fields.FrontDoorRegisters) {
      return parseRegisterTable(rtNode);
    }
  }

  return null;
}

/**
 * 解析 Lua 寄存器（簡化版本）
 */
export function parseLuaRegister(content: string): LuaRegister | null {
  let ast: any;
  try {
    ast = luaparse.parse(content, {
      lax: true,
      scope: true
    });
  } catch (err) {
    console.error('Error parsing Lua content:', err);
    return null;
  }

  const regNodes = findNodes(ast, 'TableConstructorExpression');

  for (const regNode of regNodes) {
    const fields = parseTableFields(regNode);
    if (fields.Name) {
      return parseRegister(regNode);
    }
  }

  return null;
}
