import { RegisterTableViewModel } from '@/types'

interface MainContentProps {
  selectedRegisterTable?: RegisterTableViewModel
  registerTables: RegisterTableViewModel[]
  onRegisterTableSelect: (table: RegisterTableViewModel) => void
}

export function MainContent({
  selectedRegisterTable,
  registerTables,
  onRegisterTableSelect
}: MainContentProps) {
  return (
    <div className="flex-1 flex flex-col bg-white">
      {/* Byte Grid */}
      <div className="h-32 border-b border-gray-300 p-4">
        <div className="text-sm font-medium text-gray-700 mb-2">Byte Data</div>
        <div className="grid grid-cols-16 gap-1 text-xs font-mono">
          {/* 這裡會顯示16進制的byte數據 */}
          {Array.from({ length: 16 }, (_, i) => (
            <div key={i} className="text-center p-1 border border-gray-200">
              {i.toString(16).toUpperCase().padStart(2, '0')}
            </div>
          ))}
        </div>
      </div>

      {/* 過濾器 */}
      {selectedRegisterTable && (
        <div className="h-12 border-b border-gray-300 p-4 flex items-center">
          <label className="text-sm font-medium text-gray-700 mr-2">過濾：</label>
          <input
            type="text"
            placeholder="輸入過濾條件..."
            className="flex-1 px-3 py-1 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
        </div>
      )}

      {/* 暫存器列表 */}
      <div className="flex-1 overflow-auto p-4">
        <div className="text-sm font-medium text-gray-700 mb-2">暫存器</div>
        <div className="space-y-1">
          {/* 這裡會顯示暫存器列表 */}
          {selectedRegisterTable?.Registers.map((register, index) => (
            <div key={index} className="flex items-center space-x-4 p-2 border border-gray-200 rounded">
              <span className="w-32 text-sm font-medium">{register.Name}</span>
              <span className="w-32 text-sm text-gray-600">{register.Group}</span>
              <span className="w-16 text-sm font-mono">0x{register.Addr.toString(16).toUpperCase()}</span>
              <input
                type="text"
                value={register.DAC}
                className="w-20 px-2 py-1 border border-gray-300 rounded text-sm"
                readOnly
              />
              <span className="text-sm text-gray-500">{register.Unit || ''}</span>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}