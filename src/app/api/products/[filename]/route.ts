import { NextResponse } from 'next/server'
import fs from 'fs'
import path from 'path'
import { parseLuaProduct, LuaProduct } from '@/lib/lua/luaParser'

const LUA_SCRIPTS_DIR = path.join(process.cwd(), 'public', 'scripts', 'lua')

// 安全的數學表達式計算函數（模仿 GMT2026 的 MoonSharp CalcDACValueExpr）
// 支持參數化和動態重新計算
// 參數格式：
// - [XXX_Value] - 取名為 XXX 的 Register 的當前 DACValues 值
// - [XXX_DAC] - 取名為 XXX 的 Register 的 DAC 索引值
// - [XXX] - 取參數值（從 externalParameters 或預設值）
export function calculateDACValues(
  dacValueExpr: string,
  valuesCount: number = 256,
  externalParameters: Record<string, number> = {},
  registerMap: Record<string, { DAC: number, DACValues: (string | number)[] }> = {}
): (string | number)[] {
  if (!dacValueExpr || valuesCount <= 0) return []

  // 檢查是否有 lookup 函數
  const lookupMatch = dacValueExpr.match(/lookup\(([^)]*)\)/)
  if (lookupMatch) {
    const optionsStr = lookupMatch[1]
    const options = optionsStr.split(',').map(s => {
      const trimmed = s.trim().replace(/^['"]|['"]$/g, '')
      const num = parseFloat(trimmed)
      return isNaN(num) ? trimmed : num
    })
    if (options.length > 0) return options
  }

  console.log(`calculateDACValues: expr="${dacValueExpr}"`)
  console.log(`calculateDACValues: externalParameters=`, externalParameters)
  console.log(`calculateDACValues: registerMap keys=`, Object.keys(registerMap))

  // 通用表達式求值器
  const evaluateExpression = (dac: number): number => {
    try {
      // 轉換表達式：處理 [XXX_Value], [XXX_DAC], [XXX] 等參數
      let processedExpr = dacValueExpr
        .replace(/\[\s*([^\]]+)\s*\]/g, (_, paramName) => {
          const name = paramName.trim()

          // [DAC] - 當前 DAC 索引
          if (name === 'DAC') {
            return String(dac)
          }

          // [XXX_Value] - 取 XXX Register 的當前 DACValues 值
          if (name.endsWith('_Value')) {
            const regName = name.slice(0, -6) // 移除 '_Value' 後綴
            const reg = registerMap[regName]
            if (reg && reg.DACValues.length > 0) {
              // 使用該 Register 的當前 DAC 值作為索引
              const index = Math.min(reg.DAC, reg.DACValues.length - 1)
              const value = reg.DACValues[index]
              if (typeof value === 'number') {
                return String(value)
              }
              return '0' // 無法解析的值返回 0
            }
            return '0' // Register 不存在時返回 0
          }

          // [XXX_DAC] - 取 XXX Register 的 DAC 索引值
          if (name.endsWith('_DAC')) {
            const regName = name.slice(0, -4) // 移除 '_DAC' 後綴
            const reg = registerMap[regName]
            if (reg) {
              return String(reg.DAC)
            }
            return '0' // Register 不存在時返回 0
          }

          // [XXX] - 一般參數
          return String(externalParameters[name] ?? 1000)
        })
        // 數學運算子轉換
        .replace(/&&/g, ' && ')
        .replace(/\|\|/g, ' || ')
        .replace(/!=/g, ' !== ')
        .replace(/!/g, '!')
        // 數學函數
        .replace(/\bMin\(/g, 'Math.min(')
        .replace(/\bMax\(/g, 'Math.max(')
        .replace(/\bAbs\(/g, 'Math.abs(')
        .replace(/\bSqrt\(/g, 'Math.sqrt(')
        .replace(/\bPow\(/g, 'Math.pow(')

      console.log(`dac=${dac}: processedExpr="${processedExpr}"`)

      // 執行表達式
      const result = eval(processedExpr)

      // 處理結果
      if (typeof result === 'number') {
        if (isNaN(result)) {
          console.log(`dac=${dac}: result is NaN, returning 0`)
          return 0
        }
        if (!isFinite(result)) {
          console.log(`dac=${dac}: result is infinite (${result}), returning 9999999`)
          return result > 0 ? 9999999 : 0
        }
        // 四捨五入到小數點後2位
        const rounded = Math.round(result * 100) / 100
        console.log(`dac=${dac}: result=${result} -> ${rounded}`)
        return rounded
      }
      console.log(`dac=${dac}: result is not a number, returning 0`)
      return 0
    } catch (e) {
      console.warn(`DAC expression error: ${e}, expr: ${dacValueExpr}, dac=${dac}`)
      return 0
    }
  }

  const values: (string | number)[] = []
  for (let dac = 0; dac < valuesCount; dac++) {
    const value = evaluateExpression(dac)
    values.push(value)
  }

  return values
}

// 計算表達式對於單個 DAC 值（用於實時計算）
// 參數格式：
// - [XXX_Value] - 取名為 XXX 的 Register 的當前 DACValues 值
// - [XXX_DAC] - 取名為 XXX 的 Register 的 DAC 索引值
export function evaluateDACExpression(
  dacValueExpr: string,
  dac: number,
  externalParameters: Record<string, number> = {},
  registerMap: Record<string, { DAC: number, DACValues: (string | number)[] }> = {}
): number {
  if (!dacValueExpr) return 0

  try {
    // 轉換表達式：處理 [XXX_Value], [XXX_DAC], [XXX] 等參數
    let processedExpr = dacValueExpr
      .replace(/\[\s*([^\]]+)\s*\]/g, (_, paramName) => {
        const name = paramName.trim()

        // [DAC] - 當前 DAC 索引
        if (name === 'DAC') {
          return String(dac)
        }

        // [XXX_Value] - 取 XXX Register 的當前 DACValues 值
        if (name.endsWith('_Value')) {
          const regName = name.slice(0, -6)
          const reg = registerMap[regName]
          if (reg && reg.DACValues.length > 0) {
            const index = Math.min(reg.DAC, reg.DACValues.length - 1)
            const value = reg.DACValues[index]
            if (typeof value === 'number') {
              return String(value)
            }
            return '0'
          }
          return '0'
        }

        // [XXX_DAC] - 取 XXX Register 的 DAC 索引值
        if (name.endsWith('_DAC')) {
          const regName = name.slice(0, -4)
          const reg = registerMap[regName]
          if (reg) {
            return String(reg.DAC)
          }
          return '0'
        }

        // [XXX] - 一般參數
        return String(externalParameters[name] ?? 1000)
      })
      .replace(/\bMin\(/g, 'Math.min(')
      .replace(/\bMax\(/g, 'Math.max(')
      .replace(/\bAbs\(/g, 'Math.abs(')
      .replace(/\bSqrt\(/g, 'Math.sqrt(')
      .replace(/\bPow\(/g, 'Math.pow(')

    const result = eval(processedExpr)

    if (typeof result === 'number') {
      if (isNaN(result) || !isFinite(result)) return 0
      return Math.round(result * 100) / 100
    }
    return 0
  } catch (e) {
    console.warn(`evaluateDACExpression error: ${e}, expr: ${dacValueExpr}`)
    return 0
  }
}

export async function GET(
  request: Request,
  { params }: { params: { filename: string } }
) {
  try {
    const filename = params.filename

    // 安全檢查
    if (filename.includes('..') || filename.includes('/')) {
      return NextResponse.json({ error: '無效的文件名' }, { status: 400 })
    }

    const filePath = path.join(LUA_SCRIPTS_DIR, filename)

    if (!fs.existsSync(filePath)) {
      return NextResponse.json({ error: '檔案不存在' }, { status: 404 })
    }

    const content = fs.readFileSync(filePath, 'utf-8')

    // 使用 luaparse 解析
    const product = parseLuaProduct(content)

    // 提取規則
    const rules = product.Rules || {}

    // 轉換為前端格式
    const registerTables = product.RegisterTable.map((rt: any) => {
      // 先收集所有 Register 的基本信息，用於跨 Register 參考
      const registerMap: Record<string, { DAC: number, DACValues: (string | number)[] }> = {}
      const rawRegisters = Object.values(rt.FrontDoorRegisters || {})

      // 先遍歷一次，填充 registerMap 的基本信息（使用臨時 DACValues）
      for (const reg of rawRegisters) {
        registerMap[reg.Name] = {
          DAC: reg.DAC ?? 0,
          DACValues: [] // 稍後會填充實際的 DACValues
        }
      }

      // 轉換 Registers 並計算 DACValues
      const registers = rawRegisters.map((reg: any) => {
        // 計算 DACValues（傳入 registerMap 以支持跨 Register 參考）
        const dacValues = calculateDACValues(reg.DACValueExpr || '', 256, {}, registerMap)
        const isCheckbox = reg.IsCheckBox === true

        console.log(`[API] Register ${reg.Name}: DACValueExpr="${reg.DACValueExpr}"`)
        console.log(`[API] Register ${reg.Name}: DACValues count=${dacValues.length}, values=`, dacValues.slice(0, 10))

        // 更新 registerMap 中該 Register 的 DACValues
        registerMap[reg.Name] = {
          DAC: reg.DAC ?? 0,
          DACValues: dacValues
        }

        // 檢測是否有依賴參數
        const paramNames: string[] = []
        if (reg.DACValueExpr) {
          const matches = reg.DACValueExpr.matchAll(/\[([^\]]+)\]/g)
          for (const m of matches) {
            const name = m[1].trim()
            if (name !== 'DAC') paramNames.push(name)
          }
        }

        return {
          Name: reg.Name,
          Group: reg.Group || '',
          Addr: reg.MemI_B0?.Addr ?? 0,
          MSB: reg.MemI_B0?.MSB ?? 7,
          LSB: reg.MemI_B0?.LSB ?? 0,
          DACValueExpr: reg.DACValueExpr || '',
          DACValues: dacValues,
          IsCheckBox: isCheckbox,
          DAC: reg.DAC ?? 0,
          Unit: reg.Unit || '',
          ReadOnly: !!reg.ReadOnly,
          IsTextBlock: !!reg.IsTextBlock,
          ValuesCount: dacValues.length,
          DependentParameters: paramNames
        }
      })

      // 按地址排序
      registers.sort((a, b) => a.Addr - b.Addr)

      return {
        Name: rt.Name,
        DeviceAddress: rt.DeviceAddress || [],
        NeedShowMemIndex: rt.NeedShowMemIndex || [],
        ChecksumMemIndexCollect: rt.ChecksumMemIndexCollect || {},
        Registers: registers
      }
    })

    const deviceAddressesView = registerTables.flatMap((rt: any) =>
      (rt.DeviceAddress || []).map((addr: number) => ({
        RegisterTableName: rt.Name,
        Value: addr
      }))
    )

    return NextResponse.json({
      filename,
      product: {
        Name: product.Name,
        Type: product.Type,
        Application: product.Application,
        RegisterTable: registerTables
      },
      functions: [],
      rules: rules,  // 包含規則列表
      size: content.length
    })
  } catch (error) {
    console.error('錯誤:', error)
    return NextResponse.json({ error: String(error) }, { status: 500 })
  }
}
