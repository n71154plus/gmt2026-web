import { NextResponse } from 'next/server'
import { executeLuaCode, validateLuaSyntax, getAvailableFunctions, parseLuaFunction } from '@/lib/lua'

export async function POST(request: Request) {
  try {
    const { scriptName, functionName, parameters, luaCode } = await request.json()

    // 獲取可用函數列表
    if (request.method === 'GET') {
      const functions = getAvailableFunctions()
      return NextResponse.json({ functions })
    }

    // 執行 Lua 腳本
    if (luaCode && !scriptName) {
      // 解析腳本中的函數
      const parsedFunctions = parseLuaFunction(luaCode)
      return NextResponse.json({
        success: true,
        functions: parsedFunctions
      })
    }

    // 執行函數
    const code = luaCode || `-- 內建函數\nfunction ${functionName}()\n  return 0\nend`
    const result = executeLuaCode(code, functionName, parameters || [])

    return NextResponse.json(result)
  } catch (error) {
    console.error('Lua腳本執行失敗:', error)
    return NextResponse.json(
      { error: 'Lua腳本執行失敗', details: error instanceof Error ? error.message : '未知錯誤' },
      { status: 500 }
    )
  }
}

// 獲取可用函數列表
export async function GET() {
  const functions = getAvailableFunctions()
  return NextResponse.json({ functions })
}
