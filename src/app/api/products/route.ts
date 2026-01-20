import { NextResponse } from 'next/server'
import fs from 'fs'
import path from 'path'

const LUA_SCRIPTS_DIR = path.join(process.cwd(), 'public', 'scripts', 'lua')

// 從 Lua 腳本文件提取產品信息
function parseProductInfo(filename: string, content: string) {
  // 嘗試匹配 New.Product{...} 格式
  const productMatch = content.match(/New\.Product\s*\{([^}]+)\}/s)

  if (productMatch) {
    const productBlock = productMatch[1]

    const nameMatch = productBlock.match(/Name\s*=\s*["']([^"']+)["']/)
    const typeMatch = productBlock.match(/Type\s*=\s*["']([^"']+)["']/)
    const appMatch = productBlock.match(/Application\s*=\s*["']([^"']+)["']/)
    const descMatch = productBlock.match(/Description\s*=\s*["']([^"']+)["']/)
    const packageMatch = productBlock.match(/Package\s*=\s*["']([^"']+)["']/)

    return {
      Product: {
        Name: nameMatch?.[1] || filename.replace('.lua', ''),
        Type: typeMatch?.[1] || 'Unknown',
        Application: appMatch?.[1] || 'General',
        Package: packageMatch?.[1] || '',
        Description: descMatch?.[1] || `${filename.replace('.lua', '')} 設備配置`
      },
      FileName: filename,
      HasContent: content.length > 0
    }
  }

  // 備用：嘗試匹配舊格式
  const nameMatch = content.match(/ProductName\s*=\s*["']([^"']+)["']/)
  const typeMatch = content.match(/ProductType\s*=\s*["']([^"']+)["']/)
  const appMatch = content.match(/Application\s*=\s*["']([^"']+)["']/)
  const descMatch = content.match(/Description\s*=\s*["']([^"']+)["']/)

  return {
    Product: {
      Name: nameMatch?.[1] || filename.replace('.lua', ''),
      Type: typeMatch?.[1] || 'Unknown',
      Application: appMatch?.[1] || 'General',
      Package: '',
      Description: descMatch?.[1] || `${filename.replace('.lua', '')} 設備配置`
    },
    FileName: filename,
    HasContent: content.length > 0
  }
}

export async function GET() {
  try {
    // 檢查目錄是否存在
    if (!fs.existsSync(LUA_SCRIPTS_DIR)) {
      return NextResponse.json([])
    }

    // 讀取目錄中的所有 Lua 文件
    const files = fs.readdirSync(LUA_SCRIPTS_DIR)
      .filter(file => file.endsWith('.lua'))

    // 解析每個文件的信息
    const products = files.map(filename => {
      const filePath = path.join(LUA_SCRIPTS_DIR, filename)
      const content = fs.readFileSync(filePath, 'utf-8')
      return parseProductInfo(filename, content)
    })

    return NextResponse.json(products)
  } catch (error) {
    console.error('載入產品列表失敗:', error)
    return NextResponse.json({ error: '載入產品列表失敗' }, { status: 500 })
  }
}
