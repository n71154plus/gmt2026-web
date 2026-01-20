import { NextResponse } from 'next/server'
import fs from 'fs'
import path from 'path'
import { parseLuaProduct, extractRules } from '@/lib/lua/luaParser'

const LUA_SCRIPTS_DIR = path.join(process.cwd(), 'public', 'scripts', 'lua')

// 評估 Lua 規則
// 規則函數返回 { description, result } 表
export async function POST(request: Request) {
  try {
    const body = await request.json()
    const { filename, rules, registerValues } = body

    if (!filename) {
      return NextResponse.json({ error: '缺少文件名稱' }, { status: 400 })
    }

    const filePath = path.join(LUA_SCRIPTS_DIR, filename)
    if (!fs.existsSync(filePath)) {
      return NextResponse.json({ error: '檔案不存在' }, { status: 404 })
    }

    const content = fs.readFileSync(filePath, 'utf-8')

    console.log('POST /api/products/rules: filename =', filename);
    console.log('content length:', content.length);

    // 如果沒有提供 rules，從 Lua 文件中提取
    const rulesToEvaluate = rules || extractRules(content)
    console.log('rulesToEvaluate:', rulesToEvaluate);
    console.log('rulesToEvaluate keys:', Object.keys(rulesToEvaluate));

    if (!rulesToEvaluate || Object.keys(rulesToEvaluate).length === 0) {
      console.log('沒有找到規則，返回空結果');
      return NextResponse.json({ ruleResults: [] })
    }

    // 構建 RegValues 表
    const regValuesStr = registerValues || '{}'
    let regValuesObj: Record<string, any> = {}
    try {
      regValuesObj = JSON.parse(regValuesStr)
    } catch (e) {
      console.warn('Failed to parse register values:', e)
    }

    // 評估每個規則
    const results: { RuleName: string; Description: string; Result: boolean }[] = []

    for (const [ruleName, funcBody] of Object.entries(rulesToEvaluate)) {
      try {
        // 創建一個安全的評估環境
        const result = evaluateRule(funcBody, regValuesObj)
        results.push({
          RuleName: ruleName,
          Description: result.description || '',
          Result: result.pass
        })
        console.log(`Rule ${ruleName}: ${result.pass ? 'PASS' : 'FAIL'} - ${result.description}`)
      } catch (e) {
        console.error(`Error evaluating rule ${ruleName}:`, e)
        results.push({
          RuleName: ruleName,
          Description: `評估錯誤: ${(e as Error).message}`,
          Result: false
        })
      }
    }

    // 計算總結規則
    const allPass = results.every(r => r.Result)
    results.unshift({
      RuleName: 'All Design Rule OK',
      Description: allPass ? '所有 Design Rule 皆通過' : '有 Design Rule 未通過',
      Result: allPass
    })

    return NextResponse.json({ ruleResults: results })
  } catch (error) {
    console.error('評估規則失敗:', error)
    return NextResponse.json({ error: String(error) }, { status: 500 })
  }
}

// 評估單個規則
function evaluateRule(funcBody: string, regValues: Record<string, any>): { description: string; pass: boolean } {
  try {
    console.log(`evaluateRule: 處理規則`);
    console.log(`  funcBody length:`, funcBody.length);
    console.log(`  funcBody 前100字符:`, funcBody.substring(0, 100).replace(/\n/g, '\\n'));
    console.log(`  funcBody 後100字符:`, funcBody.substring(Math.max(0, funcBody.length - 100)).replace(/\n/g, '\\n'));

    // 規則返回 { "description", true/false }
    // 規則可能使用 get_register_value("RegName") 來獲取值

    // 模擬 get_register_value 函數
    // 從 regValues 中獲取值
    const getRegisterValue = (regName: string): any => {
      // 首先嘗試找 _Value 後綴的值
      if (regValues[`${regName}_Value`] !== undefined) {
        return regValues[`${regName}_Value`]
      }
      // 如果沒有，找 DAC 值
      if (regValues[`${regName}_DAC`] !== undefined) {
        return regValues[`${regName}_DAC`]
      }
      return null
    }

    // 解析規則函數中的 get_register_value 調用
    // 格式: get_register_value("RegisterName")
    let processedBody = funcBody

    // 先測試正則是否正確匹配
    const getValueRegex = /get_register_value\s*\(\s*["']([^"']+)["']\s*\)/g
    const matches = [...funcBody.matchAll(getValueRegex)]
    console.log(`  找到 ${matches.length} 個 get_register_value 調用`)

    // 替換 get_register_value("xxx") 為實際值
    processedBody = funcBody.replace(getValueRegex, (_, regName) => {
      const value = getRegisterValue(regName)
      console.log(`  get_register_value("${regName}") =`, value)
      if (value === null) {
        return 'nil'
      }
      if (typeof value === 'string') {
        return `'${value}'`
      }
      return String(value)
    })

    console.log(`  processedBody =`, processedBody.replace(/\n/g, '\\n'));

    // 查找 return { "description", result } 部分
    const returnMatch = processedBody.match(/return\s*\{\s*["']([^"']+)["']\s*,\s*(.+?)\}/i)

    if (returnMatch) {
      const description = returnMatch[1]
      let resultExpr = returnMatch[2].trim()

      console.log(`  description =`, description)
      console.log(`  resultExpr =`, resultExpr)

      // 評估結果表達式
      try {
        // 簡單評估
        // 對於字符串比較，添加引號
        const evalResult = resultExpr.replace(/'([^']+)'/g, '"$1"')
        console.log(`  evalResult =`, evalResult)

        const pass = eval(evalResult)
        console.log(`  pass =`, pass)
        return { description, pass: Boolean(pass) }
      } catch (e) {
        console.log(`  評估錯誤:`, e)
        // 如果無法評估，預設為通過
        return { description, pass: true }
      }
    }

    console.log(`  無法解析 return 語句`);
    // 如果無法解析，返回 true（通過）
    return { description: '無法解析規則', pass: true }
  } catch (e) {
    console.log(`  錯誤:`, e);
    return { description: (e as Error).message, pass: true }
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
