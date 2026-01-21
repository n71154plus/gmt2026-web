import { NextResponse } from 'next/server'
import fs from 'fs'
import path from 'path'
import { parseLuaProduct, LuaProduct } from '@/lib/lua/luaParser'
import { calculateDACValues } from '@/lib/lua/dacCalculator'

const LUA_SCRIPTS_DIR = path.join(process.cwd(), 'public', 'scripts', 'lua')

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
      const rawRegisters = Object.values(rt.FrontDoorRegisters || {}) as any[]

      // 先遍歷一次，填充 registerMap 的基本信息（使用臨時 DACValues）
      for (const reg of rawRegisters) {
        registerMap[reg.Name] = {
          DAC: reg.DAC ?? 0,
          DACValues: [] // 稍後會填充實際的 DACValues
        }
      }

      // 第一次遍歷：計算沒有跨Register引用的DACValues
      rawRegisters.forEach((reg: any) => {
        // 簡單檢查是否有可能的跨Register引用
        const hasCrossRef = reg.DACValueExpr &&
          (reg.DACValueExpr.includes('_Value') || reg.DACValueExpr.includes('_DAC'))

        if (!hasCrossRef) {
          // 沒有跨Register引用，直接計算
          const dacValues = calculateDACValues(reg.DACValueExpr || '', 256, {}, {})
          registerMap[reg.Name] = {
            DAC: reg.DAC ?? 0,
            DACValues: dacValues
          }
        }
      })

      // 第二次遍歷：計算有跨Register引用的DACValues
      const registers = rawRegisters.map((reg: any) => {
        // 計算 DACValues（現在registerMap包含了其他Register的信息）
        const dacValues = calculateDACValues(reg.DACValueExpr || '', 256, {}, registerMap)
        const isCheckbox = reg.IsCheckBox === true

        //console.log(`[API] Register ${reg.Name}: DACValueExpr="${reg.DACValueExpr}"`)
        //console.log(`[API] Register ${reg.Name}: DACValues count=${dacValues.length}, values=`, dacValues.slice(0, 10))

        // 更新 registerMap
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
