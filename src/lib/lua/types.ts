// Lua腳本類型定義

export interface LuaFunction {
  name: string
  description: string
  parameters: LuaParameter[]
  returns: LuaReturnType[]
  category: string
}

export interface LuaParameter {
  name: string
  type: 'number' | 'string' | 'boolean' | 'table'
  description: string
  optional?: boolean
  defaultValue?: string | number | boolean
}

export interface LuaReturnType {
  type: 'number' | 'string' | 'boolean' | 'table' | 'nil'
  description: string
}

export interface LuaExecutionResult {
  success: boolean
  data?: {
    result: string | number | boolean | null
    values?: (string | number | boolean)[]
    message: string
    timestamp: string
  }
  error?: string
}

export interface LuaScript {
  name: string
  content: string
  functions: LuaFunction[]
  version: string
  description: string
}

// 內建Lua函數定義
export const builtInFunctions: LuaFunction[] = [
  {
    name: 'i2c.readU8',
    description: '從I2C設備讀取8位無符號整數',
    category: 'I2C操作',
    parameters: [
      { name: 'devAddr', type: 'number', description: '設備I2C地址 (7位地址)' },
      { name: 'regAddr', type: 'number', description: '暫存器地址' }
    ],
    returns: [{ type: 'number', description: '讀取的8位值' }]
  },
  {
    name: 'i2c.readU16',
    description: '從I2C設備讀取16位無符號整數',
    category: 'I2C操作',
    parameters: [
      { name: 'devAddr', type: 'number', description: '設備I2C地址 (7位地址)' },
      { name: 'regAddr', type: 'number', description: '暫存器地址' }
    ],
    returns: [{ type: 'number', description: '讀取的16位值 (大端序)' }]
  },
  {
    name: 'i2c.writeU8',
    description: '向I2C設備寫入8位無符號整數',
    category: 'I2C操作',
    parameters: [
      { name: 'devAddr', type: 'number', description: '設備I2C地址 (7位地址)' },
      { name: 'regAddr', type: 'number', description: '暫存器地址' },
      { name: 'value', type: 'number', description: '要寫入的值 (0-255)' }
    ],
    returns: [{ type: 'boolean', description: '寫入成功返回true' }]
  },
  {
    name: 'i2c.writeU16',
    description: '向I2C設備寫入16位無符號整數',
    category: 'I2C操作',
    parameters: [
      { name: 'devAddr', type: 'number', description: '設備I2C地址 (7位地址)' },
      { name: 'regAddr', type: 'number', description: '暫存器地址' },
      { name: 'value', type: 'number', description: '要寫入的值 (0-65535)' }
    ],
    returns: [{ type: 'boolean', description: '寫入成功返回true' }]
  },
  {
    name: 'delay',
    description: '延遲指定毫秒數',
    category: '輔助函數',
    parameters: [
      { name: 'ms', type: 'number', description: '延遲時間(毫秒)' }
    ],
    returns: [{ type: 'nil', description: '無返回值' }]
  },
  {
    name: 'print',
    description: '輸出調試信息',
    category: '輔助函數',
    parameters: [
      { name: 'message', type: 'string', description: '要輸出的消息' }
    ],
    returns: [{ type: 'nil', description: '無返回值' }]
  },
  {
    name: 'bit.band',
    description: '按位與運算',
    category: '位運算',
    parameters: [
      { name: 'a', type: 'number', description: '第一個操作數' },
      { name: 'b', type: 'number', description: '第二個操作數' }
    ],
    returns: [{ type: 'number', description: '按位與結果' }]
  },
  {
    name: 'bit.bor',
    description: '按位或運算',
    category: '位運算',
    parameters: [
      { name: 'a', type: 'number', description: '第一個操作數' },
      { name: 'b', type: 'number', description: '第二個操作數' }
    ],
    returns: [{ type: 'number', description: '按位或結果' }]
  },
  {
    name: 'bit.bxor',
    description: '按位異或運算',
    category: '位運算',
    parameters: [
      { name: 'a', type: 'number', description: '第一個操作數' },
      { name: 'b', type: 'number', description: '第二個操作數' }
    ],
    returns: [{ type: 'number', description: '按位異或結果' }]
  },
  {
    name: 'bit.lshift',
    description: '左移位運算',
    category: '位運算',
    parameters: [
      { name: 'value', type: 'number', description: '要移位的值' },
      { name: 'shift', type: 'number', description: '移位位数' }
    ],
    returns: [{ type: 'number', description: '移位結果' }]
  },
  {
    name: 'bit.rshift',
    description: '右移位運算',
    category: '位運算',
    parameters: [
      { name: 'value', type: 'number', description: '要移位的值' },
      { name: 'shift', type: 'number', description: '移位位数' }
    ],
    returns: [{ type: 'number', description: '移位結果' }]
  }
]
