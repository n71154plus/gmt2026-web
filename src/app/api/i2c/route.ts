import { NextResponse } from 'next/server'

// I2C操作模擬 - 用於演示和測試

export async function POST(request: Request) {
  try {
    const { operation, address, data } = await request.json()

    // 模擬I2C操作延遲
    await new Promise(resolve => setTimeout(resolve, 100))

    // 模擬操作結果
    const result = {
      success: Math.random() > 0.1, // 90%成功率
      operation,
      address,
      data,
      timestamp: new Date().toISOString(),
      message: operation === 'read' ? '讀取成功' : '寫入成功'
    }

    if (!result.success) {
      result.message = 'I2C操作失敗：模擬錯誤'
    }

    return NextResponse.json(result)
  } catch (error) {
    console.error('I2C操作失敗:', error)
    return NextResponse.json(
      { error: 'I2C操作失敗', details: error instanceof Error ? error.message : '未知錯誤' },
      { status: 500 }
    )
  }
}