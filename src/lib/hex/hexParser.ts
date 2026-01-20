// HEX 文件類型定義

export interface HexRecord {
  length: number
  address: number
  type: number
  data: number[]
  checksum: number
}

export interface HexFile {
  records: HexRecord[]
  startAddress?: number
  extendedLinearAddress?: number
}

export interface HexParseResult {
  success: boolean
  data?: HexFile
  error?: string
  lineNumber?: number
}

// HEX 文件類型常量
export const HexRecordType = {
  DATA: 0,
  END_OF_FILE: 1,
  EXTENDED_SEGMENT_ADDRESS: 2,
  START_SEGMENT_ADDRESS: 3,
  EXTENDED_LINEAR_ADDRESS: 4,
  START_LINEAR_ADDRESS: 5
} as const

// 解析單行 HEX 記錄
export function parseHexLine(line: string, lineNumber: number = 0): HexParseResult {
  // 移除空白字符
  line = line.trim()

  // 檢查起始標記
  if (!line.startsWith(':')) {
    return { success: false, error: 'HEX 文件必須以 : 開頭', lineNumber }
  }

  // 去除起始標記
  const hexData = line.slice(1)

  // 檢查長度
  if (hexData.length < 10 || hexData.length % 2 !== 0) {
    return { success: false, error: '無效的 HEX 記錄長度', lineNumber }
  }

  try {
    // 解析各個部分
    const length = parseInt(hexData.slice(0, 2), 16)
    const address = parseInt(hexData.slice(2, 6), 16)
    const type = parseInt(hexData.slice(6, 8), 16)
    const data: number[] = []

    // 解析數據
    for (let i = 8; i < 8 + length * 2; i += 2) {
      data.push(parseInt(hexData.slice(i, i + 2), 16))
    }

    // 解析校驗和
    const checksum = parseInt(hexData.slice(8 + length * 2, 10 + length * 2), 16)

    // 驗證校驗和
    const calculatedChecksum = calculateChecksum(length, address, type, data)
    if (checksum !== calculatedChecksum) {
      return { success: false, error: `校驗和錯誤: 期望 0x${calculatedChecksum.toString(16).toUpperCase()}，實際 0x${checksum.toString(16).toUpperCase()}`, lineNumber }
    }

    return {
      success: true,
      data: {
        records: [{
          length,
          address,
          type,
          data,
          checksum
        }]
      }
    }
  } catch (e) {
    return { success: false, error: `解析錯誤: ${e instanceof Error ? e.message : '未知錯誤'}`, lineNumber }
  }
}

// 計算校驗和
function calculateChecksum(length: number, address: number, type: number, data: number[]): number {
  let sum = length + (address >> 8) + (address & 0xFF) + type
  data.forEach(byte => sum += byte)
  return ((~sum) + 1) & 0xFF
}

// 解析完整的 HEX 文件
export function parseHexFile(content: string): HexParseResult {
  const lines = content.split('\n')
  const records: HexRecord[] = []
  let extendedLinearAddress = 0
  let startAddress: number | undefined = undefined

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim()
    if (!line) continue // 跳過空行

    const result = parseHexLine(line, i + 1)

    if (!result.success) {
      return result
    }

    const record = result.data!.records[0]

    // 處理擴展線性地址
    if (record.type === HexRecordType.EXTENDED_LINEAR_ADDRESS) {
      extendedLinearAddress = (record.data[0] << 8) | record.data[1]
      record.address = extendedLinearAddress << 16
    }

    // 處理起始線性地址
    if (record.type === HexRecordType.START_LINEAR_ADDRESS) {
      startAddress = (record.data[0] << 24) | (record.data[1] << 16) | (record.data[2] << 8) | record.data[3]
    }

    records.push(record)
  }

  return {
    success: true,
    data: {
      records,
      startAddress,
      extendedLinearAddress
    }
  }
}

// 生成 HEX 記錄
export function createHexRecord(
  length: number,
  address: number,
  type: number,
  data: number[]
): string {
  const checksum = calculateChecksum(length, address, type, data)

  let record = ':'
  record += length.toString(16).padStart(2, '0').toUpperCase()
  record += address.toString(16).padStart(4, '0').toUpperCase()
  record += type.toString(16).padStart(2, '0').toUpperCase()

  data.forEach(byte => {
    record += byte.toString(16).padStart(2, '0').toUpperCase()
  })

  record += checksum.toString(16).padStart(2, '0').toUpperCase()

  return record
}

// 生成 HEX 文件結束記錄
export function createHexEndOfFile(): string {
  return createHexRecord(0, 0, HexRecordType.END_OF_FILE, [])
}

// 生成擴展線性地址記錄
export function createExtendedLinearAddress(baseAddress: number): string {
  const highByte = (baseAddress >> 24) & 0xFF
  const lowByte = (baseAddress >> 16) & 0xFF
  return createHexRecord(2, 0, HexRecordType.EXTENDED_LINEAR_ADDRESS, [lowByte, highByte])
}

// 從二進制數據生成 HEX 文件
export function createHexFromBinary(
  binaryData: number[],
  baseAddress: number = 0,
  recordSize: number = 16
): string {
  const hexRecords: string[] = []
  let currentAddress = baseAddress

  // 添加擴展線性地址
  if (baseAddress > 0xFFFF) {
    hexRecords.push(createExtendedLinearAddress(baseAddress))
    currentAddress = baseAddress & 0xFFFF
  }

  // 分割為記錄
  for (let i = 0; i < binaryData.length; i += recordSize) {
    const chunk = binaryData.slice(i, i + recordSize)
    hexRecords.push(createHexRecord(chunk.length, currentAddress, HexRecordType.DATA, chunk))
    currentAddress += chunk.length
  }

  // 添加文件結束記錄
  hexRecords.push(createHexEndOfFile())

  return hexRecords.join('\n')
}

// 從 HEX 文件提取二進制數據
export function extractBinaryFromHex(hexFile: HexFile): number[] {
  const binaryData: number[] = []
  let currentAddress = 0
  let segmentBaseAddress = 0

  for (const record of hexFile.records) {
    switch (record.type) {
      case HexRecordType.DATA:
        // 計算絕對地址
        const absoluteAddress = segmentBaseAddress + record.address

        // 填充空白區域
        while (binaryData.length < absoluteAddress) {
          binaryData.push(0xFF)
        }

        // 添加數據
        binaryData.push(...record.data)
        break

      case HexRecordType.EXTENDED_SEGMENT_ADDRESS:
        segmentBaseAddress = (record.data[0] << 8 | record.data[1]) * 16
        break

      case HexRecordType.EXTENDED_LINEAR_ADDRESS:
        segmentBaseAddress = ((record.data[0] << 8 | record.data[1]) << 16)
        break

      case HexRecordType.END_OF_FILE:
        // 文件結束
        break
    }
  }

  return binaryData
}

// 驗證 HEX 文件
export function validateHexFile(content: string): { valid: boolean; errors: string[] } {
  const errors: string[] = []

  const lines = content.split('\n')
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim()
    if (!line) continue

    const result = parseHexLine(line, i + 1)
    if (!result.success) {
      errors.push(`第 ${i + 1} 行: ${result.error}`)
    }
  }

  return {
    valid: errors.length === 0,
    errors
  }
}

// 導出類型
export type { HexParseResult }
