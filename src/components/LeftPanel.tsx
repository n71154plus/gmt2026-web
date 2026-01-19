import { ProductFileInfo, AddressEntry } from '@/types'

interface LeftPanelProps {
  availableProducts: ProductFileInfo[]
  selectedProduct?: ProductFileInfo
  deviceAddressesView: AddressEntry[]
  selectedAddress?: number
  isI2cBusy: boolean
  onProductSelect: (product: ProductFileInfo) => void
  onAddressSelect: (address: number) => void
}

export function LeftPanel({
  availableProducts,
  selectedProduct,
  deviceAddressesView,
  selectedAddress,
  isI2cBusy,
  onProductSelect,
  onAddressSelect
}: LeftPanelProps) {
  // 按應用程式分組產品
  const groupedProducts = availableProducts.reduce((groups, product) => {
    const app = product.Product.Application
    if (!groups[app]) {
      groups[app] = []
    }
    groups[app].push(product)
    return groups
  }, {} as Record<string, ProductFileInfo[]>)

  return (
    <div className="w-80 bg-white border-r border-gray-300 flex flex-col">
      {/* I2C Adapter 選擇 */}
      <div className="p-4 border-b border-gray-200">
        <label className="block text-sm font-medium text-gray-700 mb-2">
          I2C Adapter
        </label>
        <select className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500">
          <option>模擬Adapter (演示用)</option>
        </select>
      </div>

      {/* 產品選擇 */}
      <div className="p-4 border-b border-gray-200">
        <label className="block text-sm font-medium text-gray-700 mb-2">
          產品選擇
        </label>
        <select
          value={selectedProduct?.FileName || ''}
          onChange={(e) => {
            const product = availableProducts.find(p => p.FileName === e.target.value)
            if (product) onProductSelect(product)
          }}
          className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        >
          <option value="">請選擇產品</option>
          {Object.entries(groupedProducts).map(([app, products]) => (
            <optgroup key={app} label={app}>
              {products.map((product) => (
                <option key={product.FileName} value={product.FileName}>
                  {product.Product.Name}
                </option>
              ))}
            </optgroup>
          ))}
        </select>
      </div>

      {/* 設備位址選擇 */}
      <div className="p-4 border-b border-gray-200">
        <label className="block text-sm font-medium text-gray-700 mb-2">
          設備位址
        </label>
        <select
          value={selectedAddress || ''}
          onChange={(e) => onAddressSelect(parseInt(e.target.value, 16))}
          className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
        >
          <option value="">請選擇位址</option>
          {deviceAddressesView.map((entry, index) => (
            <option key={index} value={entry.Value}>
              0x{entry.Value.toString(16).toUpperCase()} ({entry.RegisterTableName})
            </option>
          ))}
        </select>
      </div>

      {/* Lua Functions */}
      <div className="flex-1 p-4 overflow-y-auto">
        <label className="block text-sm font-medium text-gray-700 mb-2">
          Lua Functions
        </label>
        <div className="space-y-2">
          {/* 這裡會動態生成按鈕 */}
          <button
            disabled={isI2cBusy}
            className="w-full px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 disabled:bg-gray-400 disabled:cursor-not-allowed text-sm"
          >
            讀取暫存器
          </button>
          <button
            disabled={isI2cBusy}
            className="w-full px-4 py-2 bg-green-500 text-white rounded hover:bg-green-600 disabled:bg-gray-400 disabled:cursor-not-allowed text-sm"
          >
            寫入暫存器
          </button>
        </div>
      </div>
    </div>
  )
}