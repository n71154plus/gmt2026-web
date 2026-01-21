import { NextResponse } from 'next/server'
import fs from 'fs'
import path from 'path'
import { extractRules, evaluateRules } from '@/lib/lua/luaParser'

// wasmoon uses WebAssembly and must run on the Node.js runtime (not Edge).
export const runtime = 'nodejs'

const LUA_SCRIPTS_DIR = path.join(process.cwd(), 'public', 'scripts', 'lua')

export async function POST(request: Request) {
  try {
    const body = await request.json()
    const { filename, registerValues } = body

    if (!filename) {
      return NextResponse.json({ error: '缺少文件名稱' }, { status: 400 })
    }

    const filePath = path.join(LUA_SCRIPTS_DIR, filename)
    if (!fs.existsSync(filePath)) {
      return NextResponse.json({ error: '檔案不存在' }, { status: 404 })
    }

    const content = fs.readFileSync(filePath, 'utf-8')

    // console.log('POST /api/products/rules: filename =', filename)
    // console.log('content length:', content.length)

    // 構建 RegValues 表
    const regValuesObj: Record<string, any> = {}
    if (registerValues) {
      try {
        const parsed = typeof registerValues === 'string' 
          ? JSON.parse(registerValues) 
          : registerValues
        Object.assign(regValuesObj, parsed)
      } catch (e) {
        console.warn('Failed to parse register values:', e)
      }
    }

    // 直接在服務端使用 wasmoon 執行規則
    const ruleResultsObj = await evaluateRules(content, regValuesObj)
    const formattedResults =
      Object.entries(ruleResultsObj).map(([ruleName, [description, passed]]) => ({
        RuleName: ruleName,
        Description: description,
        Result: passed
      }))

    // 新增整體總結結果
    if (formattedResults.length > 0) {
      const allPass = formattedResults.every(r => r.Result)
      formattedResults.unshift({
        RuleName: 'All Design Rule OK',
        Description: allPass ? '所有 Design Rule 皆通過' : '有 Design Rule 未通過',
        Result: allPass
      })
    }

    return NextResponse.json({
      ruleResults: formattedResults,
      needClientExecution: false
    })
  } catch (error) {
    console.error('評估規則失敗:', error)
    return NextResponse.json({ error: String(error) }, { status: 500 })
  }
}

// GET: 獲取產品的規則列表
export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url)
    const filename = searchParams.get('filename')

    if (!filename) {
      return NextResponse.json({ error: '缺少文件名稱' }, { status: 400 })
    }

    const filePath = path.join(LUA_SCRIPTS_DIR, filename)
    if (!fs.existsSync(filePath)) {
      return NextResponse.json({ error: '檔案不存在' }, { status: 404 })
    }

    const content = fs.readFileSync(filePath, 'utf-8')
    const rules = extractRules(content)

    return NextResponse.json({
      filename,
      rules: Object.keys(rules),
      count: Object.keys(rules).length
    })
  } catch (error) {
    console.error('獲取規則列表失敗:', error)
    return NextResponse.json({ error: String(error) }, { status: 500 })
  }
}
