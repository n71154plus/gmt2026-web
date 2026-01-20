// Lua腳本解析器 - 簡化的Lua解釋器
import { builtInFunctions, LuaFunction, LuaExecutionResult } from './types'

// Lua解釋器狀態
interface InterpreterState {
  variables: Record<string, number | string | boolean | null>
  functions: Map<string, string>
  output: (string | number)[]
}

// 創建新的解釋器狀態
function createState(): InterpreterState {
  return {
    variables: {},
    functions: new Map(),
    output: []
  }
}

// 解析Lua函數定義
export function parseLuaFunction(content: string): LuaFunction[] {
  const functions: LuaFunction[] = []
  
  // 正則匹配 function name(args) ... end 模式
  const funcPattern = /function\s+(\w+(?:\.\w+)?)\s*\(([^)]*)\)/g
  let match
  
  while ((match = funcPattern.exec(content)) !== null) {
    const name = match[1]
    const argsStr = match[2]
    
    // 解析參數
    const parameters = argsStr
      .split(',')
      .map(arg => arg.trim())
      .filter(arg => arg.length > 0)
      .map(arg => ({
        name: arg,
        type: 'number' as const,
        description: `${arg} 參數`
      }))
    
    // 根據函數名分類
    let category = '自定義函數'
    if (name.startsWith('i2c.')) category = 'I2C操作'
    else if (name.startsWith('bit.')) category = '位運算'
    else if (name === 'delay' || name === 'print') category = '輔助函數'
    
    functions.push({
      name,
      description: `${name} 函數`,
      parameters,
      returns: [{ type: 'number', description: '返回值' }],
      category
    })
  }
  
  return functions
}

// 解析表達式
function parseExpression(expr: string): { type: 'number' | 'string' | 'boolean' | 'null'; value: number | string | boolean | null } {
  expr = expr.trim()
  
  // null
  if (expr === 'nil' || expr === 'null') {
    return { type: 'null', value: null }
  }
  
  // 字符串
  if ((expr.startsWith('"') && expr.endsWith('"')) ||
      (expr.startsWith("'") && expr.endsWith("'"))) {
    return { type: 'string', value: expr.slice(1, -1) }
  }
  
  // 布爾值
  if (expr === 'true') return { type: 'boolean', value: true }
  if (expr === 'false') return { type: 'boolean', value: false }
  
  // 數字 (支持十六進制 0x 和 十進制)
  const hexMatch = expr.match(/^0x([0-9A-Fa-f]+)$/)
  if (hexMatch) {
    return { type: 'number', value: parseInt(hexMatch[1], 16) }
  }
  
  const numMatch = expr.match(/^-?\d+(\.\d+)?$/)
  if (numMatch) {
    return { type: 'number', value: parseFloat(expr) }
  }
  
  // 變量引用
  return { type: 'number', value: NaN }
}

// 執行Lua代碼
export function executeLuaCode(
  code: string,
  functionName: string,
  parameters: (number | string | boolean)[]
): LuaExecutionResult {
  const state = createState()
  
  // 內建函數實現
  const builtInImpls: Record<string, (...args: any[]) => any> = {
    'i2c.readU8': (devAddr: number, regAddr: number) => {
      state.output.push(`讀取設備 0x${devAddr.toString(16)} 暫存器 0x${regAddr.toString(16)}`)
      return Math.floor(Math.random() * 256)
    },
    'i2c.readU16': (devAddr: number, regAddr: number) => {
      state.output.push(`讀取設備 0x${devAddr.toString(16)} 暫存器 0x${regAddr.toString(16)} (16位)`)
      return Math.floor(Math.random() * 65536)
    },
    'i2c.writeU8': (devAddr: number, regAddr: number, value: number) => {
      state.output.push(`寫入設備 0x${devAddr.toString(16)} 暫存器 0x${regAddr.toString(16)} 值 0x${value.toString(16)}`)
      return true
    },
    'i2c.writeU16': (devAddr: number, regAddr: number, value: number) => {
      state.output.push(`寫入設備 0x${devAddr.toString(16)} 暫存器 0x${regAddr.toString(16)} 值 0x${value.toString(16)} (16位)`)
      return true
    },
    'delay': (ms: number) => {
      state.output.push(`延遲 ${ms}ms`)
      return null
    },
    'print': (msg: string) => {
      state.output.push(msg)
      return null
    },
    'bit.band': (a: number, b: number) => a & b,
    'bit.bor': (a: number, b: number) => a | b,
    'bit.bxor': (a: number, b: number) => a ^ b,
    'bit.lshift': (value: number, shift: number) => value << shift,
    'bit.rshift': (value: number, shift: number) => value >> shift
  }
  
  try {
    // 解析函數定義
    const funcMatch = new RegExp(
      `function\\s+${functionName.replace('.', '\\.')}\\s*\\(([^)]*)\\)\\s*([\\s\\S]*?)\\s*end`,
      'i'
    ).exec(code)
    
    if (!funcMatch) {
      // 檢查是否是內建函數
      if (builtInImpls[functionName]) {
        const result = builtInImpls[functionName](...parameters)
        return {
          success: true,
          data: {
            result,
            values: parameters,
            message: state.output.join('\n') || `執行 ${functionName} 成功`,
            timestamp: new Date().toISOString()
          }
        }
      }
      return { success: false, error: `函數 ${functionName} 未找到` }
    }
    
    const args = funcMatch[1].split(',').map((a: string) => a.trim())
    const body = funcMatch[2]
    
    // 設置參數為變量
    parameters.forEach((param, index) => {
      if (args[index]) {
        state.variables[args[index]] = param
      }
    })
    
    // 解析並執行函數體
    // 簡化處理：模擬執行
    state.output.push(`執行 ${functionName}(${parameters.join(', ')})`)
    
    // 解析返回值語句 return xxx
    const returnMatch = /return\s+([^;\n]+)/i.exec(body)
    let result: number | string | boolean | null = 0
    
    if (returnMatch) {
      const returnExpr = returnMatch[1].trim()
      
      // 檢查是否有內建函數調用
      for (const [name, impl] of Object.entries(builtInImpls)) {
        if (returnExpr.includes(name)) {
          const vars = Object.values(state.variables) as number[]
          result = impl(...vars)
          break
        }
      }
      
      // 解析數學表達式
      if (!isNaN(Number(returnExpr)) || returnExpr.startsWith('0x')) {
        result = parseExpression(returnExpr).value as number
      }
    }
    
    return {
      success: true,
      data: {
        result,
        values: parameters,
        message: state.output.join('\n'),
        timestamp: new Date().toISOString()
      }
    }
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : '執行錯誤'
    }
  }
}

// 獲取所有可用的Lua函數
export function getAvailableFunctions(): LuaFunction[] {
  return builtInFunctions
}

// 驗證Lua語法
export function validateLuaSyntax(code: string): { valid: boolean; errors: string[] } {
  const errors: string[] = []
  
  // 檢查括號匹配
  let parenDepth = 0
  let braceDepth = 0
  
  for (let i = 0; i < code.length; i++) {
    const char = code[i]
    if (char === '(') parenDepth++
    if (char === ')') parenDepth--
    if (char === '{') braceDepth++
    if (char === '}') braceDepth--
    
    if (parenDepth < 0) {
      errors.push(`第 ${i + 1} 行: 意外的右括號`)
      parenDepth = 0
    }
    if (braceDepth < 0) {
      errors.push(`第 ${i + 1} 行: 意外的大括號`)
      braceDepth = 0
    }
  }
  
  if (parenDepth > 0) {
    errors.push('未閉合的括號')
  }
  if (braceDepth > 0) {
    errors.push('未閉合的大括號')
  }
  
  // 檢查 function/end 配對
  const funcMatches = code.match(/function\s+\w+(\.\w+)?\s*\(/g)
  const endMatches = code.match(/end\s*/g)
  
  if (funcMatches && endMatches) {
    if (funcMatches.length !== endMatches.length) {
      errors.push('function/end 數量不匹配')
    }
  }
  
  return { valid: errors.length === 0, errors }
}
