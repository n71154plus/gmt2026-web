import { NextResponse } from 'next/server'

// 模擬產品數據載入
export async function GET(
  request: Request,
  { params }: { params: { filename: string } }
) {
  try {
    const filename = params.filename

    // 根據文件名返回對應的產品數據
    // 目前使用模擬數據
    const mockProductData = {
      Name: filename.replace('.lua', ''),
      Type: 'LS',
      Application: 'NoteBook',
      Package: '',
      Description: `${filename.replace('.lua', '')} Level Shift IC`,
      RegisterTable: [
        {
          Name: 'Default',
          DeviceAddress: [0x5E],
          Registers: [
            {
              Name: 'CS_CLK_Interval',
              Group: 'Charge Sharing Setting',
              Addr: 0x02,
              MSB: 4,
              LSB: 2,
              DACValueExpr: 'lookup(\'Disable\',\'1us\',\'1.5us\',\'2us\',\'2.5us\',\'3us\',\'3.5us\',\'4us\')',
              DAC: 0,
              Unit: 'time',
              ReadOnly: false,
              IsTextBlock: false
            }
          ],
          ChecksumMemIndexCollect: {
            'Default': [0x00, 0x01, 0x02]
          },
          NeedShowMemIndex: [0x00, 0x01, 0x02, 0x04]
        }
      ]
    }

    return NextResponse.json(mockProductData)
  } catch (error) {
    console.error('載入產品數據失敗:', error)
    return NextResponse.json({ error: '載入產品數據失敗' }, { status: 500 })
  }
}