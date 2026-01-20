// 使用 luaparse 解析 Lua 文件
import luaparse from 'luaparse';

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

    // 遍歷所有屬性
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
 * 查找特定類型的第一個節點
 */
function findFirstNode(node: any, nodeType: string): any | null {
  let result: any = null;
  
  traverseNode(node, (n) => {
    if (n.type === nodeType && !result) {
      result = n;
    }
  });
  
  return result;
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

  // 直接是 TableConstructorExpression
  if (node.type === 'TableConstructorExpression') {
    return node;
  }

  // TableCallExpression: New.RegisterTable{...}
  if (node.type === 'TableCallExpression') {
    // 首先檢查 arguments
    if (node.arguments && node.arguments.type === 'TableConstructorExpression') {
      return node.arguments;
    }

    // 當 base 是 MemberExpression 且包含 TableConstructorExpression 時
    if (node.base && node.base.type === 'MemberExpression') {
      if (node.base.base && node.base.base.type === 'TableConstructorExpression') {
        return node.base.base;
      }
      if (node.base.index && node.base.index.type === 'TableConstructorExpression') {
        return node.base.index;
      }
    }

    // 如果 base 本身就是 TableConstructorExpression
    if (node.base && node.base.type === 'TableConstructorExpression') {
      return node.base;
    }
  }

  // MemberExpression: New.Register (後面跟 {...} 時)
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
function parseTableFields(tableNode: any, debugName: string = 'table'): { [key: string]: any } {
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
    let numericKey: number | undefined;

    // 處理不同的 key 類型
    if (field.key) {
      if (field.key.type === 'Identifier') {
        key = field.key.name;
      } else if (field.key.type === 'StringLiteral') {
        key = extractString(field.key);
      } else if (field.key.type === 'NumericLiteral') {
        const num = extractNumber(field.key);
        if (num !== undefined) {
          numericKey = num;
          key = String(num);
        }
      }
    }

    if (key !== undefined && field.value) {
      // 遞歸處理嵌套的表
      if (field.value.type === 'TableConstructorExpression') {
        result[key] = parseTableFields(field.value, key);
      } else if (field.value.type === 'TableCallExpression') {
        const table = getTableFromNode(field.value);
        if (table) {
          result[key] = parseTableFields(table, key);
        } else {
          // Fallback: 從 base 的 MemberExpression 中提取 TableConstructorExpression
          if (field.value.base && field.value.base.type === 'MemberExpression') {
            const base = field.value.base;
            if (base.base && base.base.type === 'TableConstructorExpression') {
              result[key] = parseTableFields(base.base, key);
            } else if (base.index && base.index.type === 'TableConstructorExpression') {
              result[key] = parseTableFields(base.index, key);
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
          result[key] = parseTableFields(table, key);
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
        // 保留函數表達式節點
        result[key] = field.value;
      } else {
        const table = getTableFromNode(field.value);
        if (table) {
          result[key] = parseTableFields(table, key);
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

  // 獲取實際的表節點
  const tableNode = getTableFromNode(regNode);
  if (!tableNode || !tableNode.fields) {
    return reg;
  }

  const fields = parseTableFields(tableNode, 'Register');

  if (fields.Name !== undefined) reg.Name = fields.Name;
  if (fields.Group !== undefined) reg.Group = fields.Group;
  if (fields.Unit !== undefined) reg.Unit = fields.Unit;
  if (fields.DAC !== undefined) reg.DAC = fields.DAC;
  if (fields.DACValueExpr !== undefined) reg.DACValueExpr = fields.DACValueExpr;
  if (fields.ReadOnly !== undefined) reg.ReadOnly = fields.ReadOnly;
  if (fields.IsTextBlock !== undefined) reg.IsTextBlock = fields.IsTextBlock;

  // 解析 MemI_B0 和 MemI_B1
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

    // 解析 FrontDoorRegisters
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

  // 如果是 TableCallExpression，直接獲取 arguments（luaparse 中 arguments 直接是 TableConstructorExpression）
  if (rtNode && rtNode.type === 'TableCallExpression') {
    const arg = rtNode.arguments;
    if (arg && arg.type === 'TableConstructorExpression') {
      return parseRegisterTable(arg);
    }

    // 嘗試從 arguments[0] 獲取（兼容性）
    if (arg && Array.isArray(arg) && arg.length > 0) {
      const innerArg = arg[0];
      if (innerArg && innerArg.type === 'TableConstructorExpression') {
        return parseRegisterTable(innerArg);
      }
    }
  }

  // 獲取實際的表節點
  const tableNode = getTableFromNode(rtNode);
  if (!tableNode || !tableNode.fields) {
    if (rtNode && rtNode.fields) {
      const fields = parseTableFields(rtNode, 'RegisterTable');
      table.Name = fields.Name || 'Default';
      table.DeviceAddress = fields.DeviceAddress || [];
    }
    return table;
  }

  const fields = parseTableFields(tableNode, 'RegisterTable');

  if (fields.Name !== undefined) table.Name = fields.Name;
  if (fields.DeviceAddress) table.DeviceAddress = fields.DeviceAddress;

  // 解析 FrontDoorRegisters
  if (fields.FrontDoorRegisters && typeof fields.FrontDoorRegisters === 'object') {
    for (const [regName, regData] of Object.entries(fields.FrontDoorRegisters)) {
      // 如果 regData 是原始 AST 節點（TableCallExpression），嘗試解析它
      let parsedRegData = regData;
      if (regData && typeof regData === 'object' && (regData as any).type === 'TableCallExpression') {
        const tableNode = getTableFromNode(regData);
        if (tableNode && tableNode.fields) {
          parsedRegData = parseTableFields(tableNode, regName);
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

  // 解析 BackDoorRegisters
  if (fields.BackDoorRegisters && typeof fields.BackDoorRegisters === 'object') {
    table.BackDoorRegisters = {};
    for (const [regName, regData] of Object.entries(fields.BackDoorRegisters)) {
      if (regData && typeof regData === 'object') {
        table.BackDoorRegisters[regName] = parseRegister(regData as any);
      }
    }
  }

  // 解析 NeedShowMemIndex
  if (fields.NeedShowMemIndex) table.NeedShowMemIndex = fields.NeedShowMemIndex;

  // 解析 ChecksumMemIndexCollect
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

  // 獲取實際的表節點
  const tableNode = getTableFromNode(productNode);
  if (!tableNode || !tableNode.fields) {
    return product;
  }

  // 首先遍歷 Product 表的字段，找到 RegisterTable 的原始 AST 節點
  for (const field of tableNode.fields) {
    if (field.key && field.key.name === 'RegisterTable' && field.value) {
      // 直接處理 RegisterTable
      if (field.value.type === 'TableConstructorExpression') {
        // 檢查是否直接包含 Name, FrontDoorRegisters 等字段
        if (field.value.fields && field.value.fields.length > 0) {
          const firstField = field.value.fields[0];

          // 如果第一個字段是 TableCallExpression，說明結構是 { New.RegisterTable{...} }
          if (firstField.value && firstField.value.type === 'TableCallExpression') {
            // luaparse 中 TableCallExpression 的 arguments 直接是 TableConstructorExpression，不是數組！
            const arg = firstField.value.arguments;
            if (arg && arg.type === 'TableConstructorExpression') {
              const rt = parseRegisterTable(arg);
              product.RegisterTable.push(rt);
            } else {
              // 嘗試從 arguments[0] 獲取
              if (arg && Array.isArray(arg) && arg.length > 0) {
                const innerArg = arg[0];
                if (innerArg && innerArg.type === 'TableConstructorExpression') {
                  const rt = parseRegisterTable(innerArg);
                  product.RegisterTable.push(rt);
                }
              }
            }
          } else {
            // 一般情況，直接解析 TableConstructorExpression
            const rt = parseRegisterTable(field.value);
            product.RegisterTable.push(rt);
          }
        } else {
          const rt = parseRegisterTable(field.value);
          product.RegisterTable.push(rt);
        }
      } else if (field.value.type === 'TableCallExpression') {
        // New.RegisterTable{...}
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

  // 解析其他基本信息
  const fields = parseTableFields(tableNode, 'Product');

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
  
  // ReturnStatement -> expression
  if (node.type === 'ReturnStatement' && node.argument) {
    const arg = node.argument;
    
    // TableCallExpression: New.Product{...}
    if (arg.type === 'TableCallExpression') {
      return arg;
    }
    
    // CallExpression: New.Product() 語法
    if (arg.type === 'CallExpression') {
      return arg;
    }
    
    // 直接是 TableConstructorExpression
    if (arg.type === 'TableConstructorExpression') {
      return arg;
    }
  }
  
  // 其他情況，直接返回節點
  return node;
}

/**
 * 提取規則函數的源代碼
 */
function extractRuleSourceCode(ruleBlock: string, ruleName: string): string | null {
  try {
    const ast = luaparse.parse(ruleBlock, { lax: true });
    
    // 查找所有 TableConstructorExpression
    const tableNodes = findNodes(ast, 'TableConstructorExpression');
    
    for (const tableNode of tableNodes) {
      if (tableNode.fields) {
        for (const field of tableNode.fields) {
          if (field.key && field.key.name === ruleName) {
            const value = field.value;
            if (value && value.type === 'FunctionDeclaration') {
              return generateFunctionSource(ruleBlock, value);
            }
          }
        }
      }
    }
  } catch (err) {
    console.error('Error parsing rule block:', err);
  }
  
  return null;
}

/**
 * 生成函數源代碼
 */
function generateFunctionSource(content: string, funcNode: any): string {
  if (funcNode.range) {
    return content.substring(funcNode.range[0], funcNode.range[1] + 1);
  }
  
  let source = `${funcNode.identifier?.name || 'function'} = function(`;
  if (funcNode.parameters && funcNode.parameters.length > 0) {
    source += funcNode.parameters.map((p: any) => p.name).join(', ');
  }
  source += ') ';
  
  return source;
}

/**
 * 使用 luaparse 提取所有規則
 */
function extractRulesUsingLuaparse(content: string): { [key: string]: string } {
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
  // 注意：當解析 ruleBlock 時，funcNode.range 是相對於 ruleBlock 的，不需要額外偏移

  // 解析規則區塊
  try {
    const ast = luaparse.parse(ruleBlock, { lax: true, ranges: true });

    // 首先查找 TableConstructorExpression
    const tableNodes = findNodes(ast, 'TableConstructorExpression');

    if (tableNodes.length > 0) {
      const fields = parseTableFields(tableNodes[0]);

      for (const [ruleName, ruleValue] of Object.entries(fields)) {
        console.log(`[extractRules] Processing rule: ${ruleName}, type: ${typeof ruleValue}`);

        // 規則值可能是 FunctionExpression 節點或已解析的函數
        if (ruleValue && typeof ruleValue === 'object') {
          const rv = ruleValue as any;

          // 情況1: rv 已經是解析後的函數字符串
          if (typeof rv === 'string' && rv.trimStart().startsWith('function')) {
            rules[ruleName] = rv;
            continue;
          }

          // 情況2: rv 是原始 AST 節點 (FunctionExpression)
          if (rv.type === 'FunctionExpression' || rv.type === 'FunctionDeclaration') {
            const funcBody = extractFunctionBody(ruleBlock, rv, 0);
            if (funcBody) {
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
 * 從 AST 節點提取函數體源代碼
 */
function extractFunctionBody(content: string, funcNode: any, relativeOffset: number = 0): string | null {
  if (!funcNode) {
    return null;
  }

  // FunctionDeclaration 或 FunctionExpression
  if (funcNode.type !== 'FunctionDeclaration' && funcNode.type !== 'FunctionExpression') {
    return null;
  }

  // funcNode.range 是相對於整個文件的，需要轉換為相對於 content (ruleBlock)
  if (funcNode.range) {
    const start = funcNode.range[0] - relativeOffset;
    const end = funcNode.range[1] - relativeOffset;

    // 確保索引在有效範圍內
    if (start < 0 || end > content.length || start > end) {
      return null;
    }

    return content.substring(start, end + 1);
  }

  // 否則，嘗試從結構生成
  if (funcNode.body && funcNode.body.body) {
    return generateFunctionFromAST(funcNode);
  }

  return null;
}

/**
 * 從 AST 函數節點生成源代碼
 */
function generateFunctionFromAST(funcNode: any): string {
  // FunctionExpression 沒有 identifier
  let source = 'function(';
  if (funcNode.parameters && funcNode.parameters.length > 0) {
    source += funcNode.parameters.map((p: any) => p.name).join(', ');
  }
  source += ') ';

  // 生成函數體
  if (funcNode.body && funcNode.body.body) {
    for (const stmt of funcNode.body.body) {
      source += generateStatementFromAST(stmt);
    }
  }

  source += ' end';
  return source;
}

/**
 * 從 AST 語句節點生成源代碼
 */
function generateStatementFromAST(stmt: any): string {
  if (!stmt) return '';

  switch (stmt.type) {
    case 'ReturnStatement':
      if (stmt.argument) {
        return `return ${generateExpressionFromAST(stmt.argument)}`;
      }
      return 'return';

    case 'LocalVariableDeclaration':
      if (stmt.variables && stmt.init) {
        const names = stmt.variables.map((v: any) => v.name).join(', ');
        const values = stmt.init.map((e: any) => generateExpressionFromAST(e)).join(', ');
        return `local ${names} = ${values}`;
      }
      return '';

    case 'AssignmentStatement':
      if (stmt.variables && stmt.init) {
        const vars = stmt.variables.map((v: any) => generateExpressionFromAST(v)).join(', ');
        const vals = stmt.init.map((e: any) => generateExpressionFromAST(e)).join(', ');
        return `${vars} = ${vals}`;
      }
      return '';

    case 'IfStatement':
      let result = 'if ';
      if (stmt.condition) {
        result += generateExpressionFromAST(stmt.condition);
      }
      result += ' then ';

      if (stmt.falseClause) {
        result += generateStatementFromAST(stmt.falseClause);
      }
      result += ' end';
      return result;

    default:
      return ` -- ${stmt.type} --`;
  }
}

/**
 * 從 AST 表達式節點生成源代碼
 */
function generateExpressionFromAST(expr: any): string {
  if (!expr) return 'nil';

  switch (expr.type) {
    case 'StringLiteral':
      return expr.raw;

    case 'NumericLiteral':
      return String(expr.value || expr.raw);

    case 'BooleanLiteral':
      return expr.value ? 'true' : 'false';

    case 'Identifier':
      return expr.name;

    case 'TableConstructorExpression':
      let result = '{';
      if (expr.fields) {
        const fieldStrings = expr.fields.map((f: any) => {
          if (f.key) {
            return `[${generateExpressionFromAST(f.key)}] = ${generateExpressionFromAST(f.value)}`;
          } else {
            return generateExpressionFromAST(f.value);
          }
        });
        result += fieldStrings.join(', ');
      }
      result += '}';
      return result;

    case 'BinaryExpression':
      const left = generateExpressionFromAST(expr.left);
      const right = generateExpressionFromAST(expr.right);
      const op = expr.operator || 'and';
      return `${left} ${op} ${right}`;

    case 'CallExpression':
      let callee = generateExpressionFromAST(expr.base || expr.func);
      const args = expr.arguments?.map((a: any) => generateExpressionFromAST(a)).join(', ') || '';
      return `${callee}(${args})`;

    case 'MethodCallExpression':
      const base = generateExpressionFromAST(expr.base);
      const method = expr.method;
      const methodArgs = expr.arguments?.map((a: any) => generateExpressionFromAST(a)).join(', ') || '';
      return `${base}:${method}(${methodArgs})`;

    default:
      return ` -- ${expr.type} --`;
  }
}

/**
 * 導出的 extractRules 函數
 */
export function extractRules(content: string): { [key: string]: string } {
  return extractRulesUsingLuaparse(content);
}

/**
 * 主解析函數
 */
export function parseLuaProduct(content: string): LuaProduct {
  console.log('Parsing Lua content with luaparse AST...');
  
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
  
  // 首先查找 FunctionDeclaration（Build 函數）
  const funcNodes = findNodes(ast, 'FunctionDeclaration');
  
  if (funcNodes.length > 0) {
    // 從 Build 函數中提取返回值
    for (const funcNode of funcNodes) {
      if (funcNode.identifier && funcNode.identifier.name === 'Build') {
        // 從函數體中找到 ReturnStatement
        if (funcNode.body && funcNode.body.body) {
          for (const stmt of funcNode.body.body) {
            const productNode = extractProductFromReturnStatement(stmt);
            if (productNode) {
              const product = parseProduct(productNode);
              if (product.RegisterTable.length > 0) {
                product.Rules = extractRulesUsingLuaparse(content);
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
  
  // 如果沒有 Build 函數，查找頂層的 TableConstructorExpression
  const productNodes = findNodes(ast, 'TableConstructorExpression');
  
  if (productNodes.length === 0) {
    // 查找 TableCallExpression
    const tableCallNodes = findNodes(ast, 'TableCallExpression');
    if (tableCallNodes.length > 0) {
      const product = parseProduct(tableCallNodes[0]);
      product.Rules = extractRulesUsingLuaparse(content);
      console.log('Parsed product from TableCallExpression:', product.Name, product.Type);
      console.log('RegisterTable count:', product.RegisterTable.length);
      return product;
    }
    
    console.log('找不到 Product 表');
    return {
      Name: 'Unknown',
      Type: 'Unknown',
      Application: 'General',
      RegisterTable: []
    };
  }
  
  // 取第一個 TableConstructorExpression 作為 Product
  const product = parseProduct(productNodes[0]);
  
  // 提取規則
  product.Rules = extractRulesUsingLuaparse(content);
  
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
  console.log('Parsing RegisterTable with luaparse AST...');
  
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
  
  // 查找 RegisterTable 節點
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
  console.log('Parsing Register with luaparse AST...');
  
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
  
  // 查找 Register 節點
  const regNodes = findNodes(ast, 'TableConstructorExpression');
  
  for (const regNode of regNodes) {
    const fields = parseTableFields(regNode);
    if (fields.Name) {
      return parseRegister(regNode);
    }
  }
  
  return null;
}



