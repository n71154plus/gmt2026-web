// Lua 解析器測試
import { parseLuaFunction, executeLuaCode, validateLuaSyntax, getAvailableFunctions } from '../src/lib/lua/parser'

describe('Lua Parser', () => {
  describe('parseLuaFunction', () => {
    it('應該解析 Lua 函數定義', () => {
      const code = `
function readRegister(addr, devAddr)
  return i2c.readU8(devAddr, addr)
end

function writeRegister(addr, devAddr, value)
  i2c.writeU8(devAddr, addr, value)
  return true
end
`
      const functions = parseLuaFunction(code)

      expect(functions.length).toBe(2)
      expect(functions[0].name).toBe('readRegister')
      expect(functions[0].parameters.length).toBe(2)
      expect(functions[1].name).toBe('writeRegister')
      expect(functions[1].parameters.length).toBe(3)
    })

    it('應該正確分類函數', () => {
      const code = `
function i2c.customRead()
  return 0
end

function bit.myOperation()
  return 0
end

function myHelper()
  return 0
end
`
      const functions = parseLuaFunction(code)

      expect(functions[0].category).toBe('I2C操作')
      expect(functions[1].category).toBe('位運算')
      expect(functions[2].category).toBe('自定義函數')
    })
  })

  describe('getAvailableFunctions', () => {
    it('應該返回內建函數列表', () => {
      const functions = getAvailableFunctions()

      expect(functions.length).toBeGreaterThan(0)
      expect(functions.find(f => f.name === 'i2c.readU8')).toBeDefined()
      expect(functions.find(f => f.name === 'i2c.writeU8')).toBeDefined()
      expect(functions.find(f => f.name === 'bit.band')).toBeDefined()
    })
  })

  describe('validateLuaSyntax', () => {
    it('應該通過有效的 Lua 語法', () => {
      const code = `
function test()
  local x = 10
  return x
end
`
      const result = validateLuaSyntax(code)

      expect(result.valid).toBe(true)
      expect(result.errors.length).toBe(0)
    })

    it('應該檢測未閉合的括號', () => {
      const code = `function test(x`
      const result = validateLuaSyntax(code)

      expect(result.valid).toBe(false)
      expect(result.errors.some(e => e.includes('括號'))).toBe(true)
    })

    it('應該檢測 function/end 不匹配', () => {
      const code = `
function test()
  local x = 10
`
      const result = validateLuaSyntax(code)

      expect(result.valid).toBe(false)
    })
  })

  describe('executeLuaCode', () => {
    it('應該執行內建函數', () => {
      const result = executeLuaCode('', 'i2c.readU8', [0x5E, 0x02])

      expect(result.success).toBe(true)
      if (result.success && result.data) {
        expect(typeof result.data.result).toBe('number')
        expect(result.data.result).toBeGreaterThanOrEqual(0)
        expect(result.data.result).toBeLessThanOrEqual(255)
      }
    })

    it('應該執行用戶定義的函數', () => {
      const code = `
function customRead(devAddr, regAddr)
  local value = i2c.readU8(devAddr, regAddr)
  return value
end
`
      const result = executeLuaCode(code, 'customRead', [0x5E, 0x02])

      expect(result.success).toBe(true)
    })

    it('應該處理不存在的函數', () => {
      const result = executeLuaCode('', 'nonexistent', [])

      expect(result.success).toBe(false)
      expect(result.error).toContain('未找到')
    })
  })
})
