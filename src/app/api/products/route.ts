import { NextResponse } from 'next/server'
import fs from 'fs'
import path from 'path'

// 模擬產品數據 - 實際應該從Lua腳本解析
const mockProducts = [
  {
    Product: {
      Name: 'S102.19',
      Type: 'LS',
      Application: 'NoteBook',
      Package: '',
      Description: 'S102.19 Level Shift IC'
    },
    FileName: 'S102.19.lua'
  },
  {
    Product: {
      Name: 'P102.29',
      Type: 'PMIC',
      Application: 'NoteBook',
      Package: '',
      Description: 'P102.29 Power Management IC'
    },
    FileName: 'P102.29.lua'
  },
  {
    Product: {
      Name: 'M301.19',
      Type: 'TCON',
      Application: 'Monitor',
      Package: '',
      Description: 'M301.19 Timing Controller'
    },
    FileName: 'M301.19.lua'
  }
]

export async function GET() {
  try {
    // 在生產環境中，這裡應該解析實際的Lua腳本文件
    // 現在返回模擬數據
    return NextResponse.json(mockProducts)
  } catch (error) {
    console.error('載入產品列表失敗:', error)
    return NextResponse.json({ error: '載入產品列表失敗' }, { status: 500 })
  }
}