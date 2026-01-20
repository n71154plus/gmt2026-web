// Lua 解析器測試
import { parseHexFile, validateHexFile, createHexFromBinary, HexRecordType } from '../src/lib/hex/hexParser'

describe('HEX Parser', () => {
  describe('parseHexLine', () => {
    it('應該成功解析有效的 HEX 行', () => {
      const line = ':0200000408FA'
      const result = parseHexLine(line, 1)

      expect(result.success).toBe(true)
      if (result.success && result.data) {
        expect(result.data.records[0].length).toBe(2)
        expect(result.data.records[0].type).toBe(HexRecordType.EXTENDED_LINEAR_ADDRESS)
        expect(result.data.records[0].data).toEqual([0xFA, 0x08])
      }
    })

    it('應該拒絕無效的 HEX 行', () => {
      const line = '0200000408FA'
      const result = parseHexLine(line, 1)

      expect(result.success).toBe(false)
      expect(result.error).toContain('以 : 開頭')
    })

    it('應該校驗和錯誤', () => {
      const line = ':0200000408FB' // 錯誤的校驗和
      const result = parseHexLine(line, 1)

      expect(result.success).toBe(false)
      expect(result.error).toContain('校驗和錯誤')
    })
  })

  describe('parseHexFile', () => {
    it('應該成功解析完整的 HEX 文件', () => {
      const content = `:0200000408FA
:10000000214601360121470136007EFE09D21901
:00000001FF
`
      const result = parseHexFile(content)

      expect(result.success).toBe(true)
      if (result.success && result.data) {
        expect(result.data.records.length).toBe(3)
        expect(result.data.startAddress).toBeUndefined()
      }
    })

    it('應該處理起始線性地址記錄', () => {
      const content = `:0200000408FA
:04000000000000CB
:00000001FF
`
      const result = parseHexFile(content)

      expect(result.success).toBe(true)
      if (result.success && result.data) {
        expect(result.data.startAddress).toBe(0x000000CB)
      }
    })
  })

  describe('validateHexFile', () => {
    it('應該驗證通過有效的 HEX 文件', () => {
      const content = `:0200000408FA
:10000000214601360121470136007EFE09D21901
:00000001FF
`
      const result = validateHexFile(content)

      expect(result.valid).toBe(true)
      expect(result.errors.length).toBe(0)
    })

    it('應該報告無效 HEX 文件的錯誤', () => {
      const content = `:0200000408FB
:10000000214601360121470136007EFE09D21901
:00000001FF
`
      const result = validateHexFile(content)

      expect(result.valid).toBe(false)
      expect(result.errors.length).toBeGreaterThan(0)
    })
  })

  describe('createHexFromBinary', () => {
    it('應該從二進制數據創建 HEX 文件', () => {
      const binaryData = [0x21, 0x46, 0x01, 0x36]
      const hexContent = createHexFromBinary(binaryData, 0, 16)

      expect(hexContent).toContain(':0400000021460136')
      expect(hexContent).toContain(':00000001FF')
    })

    it('應該處理大於 64KB 的地址', () => {
      const binaryData = [0xAA, 0xBB, 0xCC, 0xDD]
      const hexContent = createHexFromBinary(binaryData, 0x10000, 16)

      expect(hexContent).toContain(':020000040001')
    })
  })
})
