import { NextResponse } from 'next/server'
import fs from 'fs'
import path from 'path'

const LUA_SCRIPTS_DIR = path.join(process.cwd(), 'public', 'scripts', 'lua')

export async function GET() {
  try {
    const filename = 'L102.19.lua'
    const filePath = path.join(LUA_SCRIPTS_DIR, filename)
    const content = fs.readFileSync(filePath, 'utf-8')

    const debugInfo: any = {}

    // 測試 1: 匹配 Product
    const productMatch = content.match(/New\.Product\s*\{([^}]+)\}/s)
    debugInfo.productMatch = productMatch ? '找到' : '未找到'

    if (productMatch) {
      const productContent = productMatch[1]
      debugInfo.productContentLength = productContent.length
      debugInfo.productContentPreview = productContent.substring(0, 300).replace(/\n/g, '\\n')

      // 測試 2: 匹配 RegisterTable = {
      const rtMatch = productContent.match(/RegisterTable\s*=\s*\{/)
      debugInfo.registerTableMatch = rtMatch ? '找到' : '未找到'
      debugInfo.rtMatchIndex = rtMatch ? rtMatch.index : -1

      if (rtMatch && rtMatch.index !== undefined) {
        const rtStart = productContent.indexOf('{', rtMatch.index + 15)
        debugInfo.registerTableStart = rtStart
        debugInfo.registerTableStartChar = rtStart >= 0 ? productContent[rtStart] : 'N/A'

        if (rtStart >= 0) {
          // 計算 depth
          let depth = 0
          let endPos = -1
          for (let i = rtStart; i < productContent.length; i++) {
            if (productContent[i] === '{') depth++
            if (productContent[i] === '}') {
              depth--
              if (depth === 0) {
                endPos = i
                break
              }
            }
          }
          debugInfo.endPos = endPos
          debugInfo.depthCalculation = '完成'

          if (endPos > rtStart) {
            const rtContent = productContent.substring(rtStart + 1, endPos)
            debugInfo.rtContentLength = rtContent.length
            debugInfo.rtContentPreview = rtContent.substring(0, 200).replace(/\n/g, '\\n')
          }
        }
      }
    }

    return NextResponse.json(debugInfo)
  } catch (error) {
    return NextResponse.json({ error: String(error) }, { status: 500 })
  }
}
