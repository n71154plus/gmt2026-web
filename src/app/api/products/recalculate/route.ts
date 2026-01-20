import { NextResponse } from 'next/server'
import fs from 'fs'
import path from 'path'
import { parseLuaProduct } from '@/lib/lua/luaParser'
import { calculateDACValues } from '../[filename]/route'

const LUA_SCRIPTS_DIR = path.join(process.cwd(), 'public', 'scripts', 'lua')

// 解析 Lua 文件獲取 DACValueExpr 和所有 Register 的 DACValues
function parseLuaFile(filename: string, targetRegName: string) {
  try {
    const filePath = path.join(LUA_SCRIPTS_DIR, filename)
    if (!fs.existsSync(filePath)) return null

    const content = fs.readFileSync(filePath, 'utf-8')
    const product = parseLuaProduct(content)

    // 查找目標 Register
    for (const rt of product.RegisterTable) {
      if (rt.FrontDoorRegisters) {
        const registers = Object.values(rt.FrontDoorRegisters)
        for (const reg of registers) {
          if (reg.Name === targetRegName) {
            return {
              dacValueExpr: reg.DACValueExpr,
              registers: registers.map((r: any) => ({
                Name: r.Name,
                DAC: r.DAC ?? 0,
                DACValueExpr: r.DACValueExpr || '',
                DefaultDAC: r.DAC ?? 0
              }))
            }
          }
        }
      }
    }

    return null
  } catch (error) {
    console.error('解析 Lua 文件失敗:', error)
    return null
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json()
    const { regName, parameters, filename } = body

    if (!regName) {
      return NextResponse.json({ error: '缺少寄存器名稱' }, { status: 400 })
    }

    // 如果提供了 filename，直接使用；否則搜索
    let targetFilename = filename
    let parsedData = null

    if (targetFilename) {
      parsedData = parseLuaFile(targetFilename, regName)
    } else {
      // 搜索所有 Lua 文件
      const files = fs.readdirSync(LUA_SCRIPTS_DIR)
      for (const file of files) {
        if (file.endsWith('.lua')) {
          parsedData = parseLuaFile(file, regName)
          if (parsedData) {
            targetFilename = file
            break
          }
        }
      }
    }

    if (!parsedData || !parsedData.dacValueExpr) {
      return NextResponse.json({ error: `找不到寄存器 ${regName} 的 DACValueExpr` }, { status: 404 })
    }

    // 構建 registerMap
    const registerMap: Record<string, { DAC: number, DACValues: (string | number)[] }> = {}

    // 首先為每個 Register 計算初始 DACValues
    for (const reg of parsedData.registers) {
      if (reg.DACValueExpr) {
        const values = calculateDACValues(reg.DACValueExpr, 256, {}, registerMap)
        registerMap[reg.Name] = {
          DAC: reg.DefaultDAC,
          DACValues: values
        }
      } else {
        // 沒有 DACValueExpr 的 Register，使用 DefaultDAC 作為索引的簡單值
        const values: (string | number)[] = []
        for (let i = 0; i < 256; i++) {
          values.push(i)
        }
        registerMap[reg.Name] = {
          DAC: reg.DefaultDAC,
          DACValues: values
        }
      }
    }

    // 使用外部參數更新 registerMap 中的 DAC 值
    for (const [key, value] of Object.entries(parameters)) {
      // 檢查是否是 _DAC 後綴的參數
      if (key.endsWith('_DAC')) {
        const regName = key.slice(0, -4)
        if (registerMap[regName]) {
          registerMap[regName].DAC = value
        }
      }
    }

    // 重新計算目標 Register 的 DACValues
    const dacValues = calculateDACValues(parsedData.dacValueExpr, 256, parameters, registerMap)

    console.log(`重新計算 ${regName} (${targetFilename}):`, parameters, '=>', dacValues.slice(0, 5), '...')

    return NextResponse.json({
      regName,
      dacValues,
      parameters
    })
  } catch (error) {
    console.error('重新計算 DAC 值失敗:', error)
    return NextResponse.json({ error: String(error) }, { status: 500 })
  }
}
