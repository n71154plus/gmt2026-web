'use client'

import { useState, useCallback, useMemo, useRef } from 'react'
import { RegisterTableViewModel, RegisterViewModel } from '@/types'

interface MainContentProps {
  selectedRegisterTable?: RegisterTableViewModel
  registerTables: RegisterTableViewModel[]
  onRegisterTableSelect: (table: RegisterTableViewModel) => void
  onRecalculateDAC?: (regName: string, parameters: Record<string, number>) => (string | number)[]
}

// 淺色系背景顏色
const GROUP_COLORS = [
  'bg-blue-50',
  'bg-green-50',
  'bg-yellow-50',
  'bg-purple-50',
  'bg-pink-50',
  'bg-indigo-50',
  'bg-teal-50',
  'bg-orange-50',
]

export function MainContent({
  selectedRegisterTable,
  registerTables,
  onRegisterTableSelect,
  onRecalculateDAC
}: MainContentProps) {
  const [filterText, setFilterText] = useState('')
  const [viewMode, setViewMode] = useState<'GroupView' | 'AddressSort'>('GroupView')
  // 使用 forceUpdate 來強制重新渲染
  const [, setForceUpdate] = useState(0)

  // 過濾寄存器
  const filteredRegisters = selectedRegisterTable?.Registers.filter(reg => {
    if (!filterText) return true
    const searchText = filterText.toLowerCase()
    return reg.Name.toLowerCase().includes(searchText) ||
           reg.Group.toLowerCase().includes(searchText) ||
           reg.Addr.toString(16).toLowerCase().includes(searchText)
  }) || []

  // 分組顯示 (群組檢視) - 按 Group 分組
  const groupedRegisters = useMemo(() => {
    return filteredRegisters.reduce((groups, reg) => {
      const group = reg.Group || 'Main'
      if (!groups[group]) groups[group] = []
      groups[group].push(reg)
      return groups
    }, {} as Record<string, RegisterViewModel[]>)
  }, [filteredRegisters])

  // 根據 NeedShowMemIndex 獲取要顯示的欄位
  const needShowMemIndex = selectedRegisterTable?.NeedShowMemIndex || []

  // 強制重新渲染
  const forceRerender = useCallback(() => {
    setForceUpdate(prev => prev + 1)
  }, [])

  // 處理寄存器值變更
  const handleRegisterChange = useCallback((reg: RegisterViewModel, newValue: number) => {
    // 更新寄存器值
    reg.DAC = newValue
    console.log(`Register ${reg.Name} value changed to: ${newValue}`)

    // 強制 UI 更新
    forceRerender()

    // 檢查哪些寄存器依賴於此寄存器
    if (selectedRegisterTable && onRecalculateDAC) {
      selectedRegisterTable.Registers.forEach(r => {
        if (r.DependentParameters && r.DependentParameters.length > 0) {
          const dependsOnThis = r.DependentParameters.some(param =>
            param.toLowerCase().includes(reg.Name.toLowerCase()) ||
            param.toLowerCase().includes(reg.Group?.toLowerCase() || '')
          )

          if (dependsOnThis) {
            const externalParams: Record<string, number> = {}
            r.DependentParameters.forEach(param => {
              const paramReg = selectedRegisterTable.Registers.find(pr =>
                pr.Name.toLowerCase().includes(param.toLowerCase()) ||
                (pr.Group && param.toLowerCase().includes(pr.Group.toLowerCase()))
              )
              if (paramReg) {
                externalParams[param] = paramReg.DAC
              }
            })

            const newDACValues = onRecalculateDAC(r.Name, externalParams)
            r.DACValues = newDACValues
            console.log(`Recalculated DACValues for ${r.Name}:`, newDACValues)
          }
        }
      })
    }
  }, [selectedRegisterTable, onRecalculateDAC, forceRerender])

  return (
    <div className="flex-1 flex flex-col bg-white">
      {/* Byte Grid - 根據 NeedShowMemIndex 顯示 */}
      <div className="h-10 border-b border-gray-300 px-2 flex items-center bg-gray-50 shrink-0">
        <span className="text-xs font-medium text-gray-700 mr-2 shrink-0">Byte Data</span>
        <div className="flex-1 overflow-x-auto">
          <div className="flex gap-0.5 min-w-max">
            {needShowMemIndex.map((index) => (
              <div
                key={`header-${index}`}
                className="w-12 text-center text-xs font-mono text-gray-600 border-l border-gray-300 pl-1"
              >
                {typeof index === 'number' ? `0x${index.toString(16).toUpperCase().padStart(2, '0')}` : index}
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* 數據行：顯示對應的值 */}
      <div className="h-8 border-b border-gray-200 px-2 flex items-center shrink-0">
        <span className="text-xs font-medium text-gray-700 mr-2 shrink-0"></span>
        <div className="flex-1 overflow-x-auto">
          <div className="flex gap-0.5 min-w-max">
            {needShowMemIndex.map((index) => (
              <div
                key={`data-${index}`}
                className="w-12 text-center text-xs font-mono text-gray-800 border-l border-gray-200 pl-1 bg-white"
              >
                --
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* 過濾器和視圖切換 */}
      {selectedRegisterTable && (
        <div className="h-12 border-b border-gray-300 p-4 flex items-center shrink-0">
          <label className="text-sm font-medium text-gray-700 mr-2">過濾：</label>
          <input
            type="text"
            value={filterText}
            onChange={(e) => setFilterText(e.target.value)}
            placeholder="輸入名稱、群組或地址..."
            className="flex-1 px-3 py-1 border border-gray-300 rounded focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          {/* 視圖模式切換 */}
          <div className="ml-4 flex border border-gray-300 rounded overflow-hidden">
            <button
              className={`px-3 py-1 text-sm ${viewMode === 'GroupView' ? 'bg-blue-500 text-white' : 'bg-white text-gray-700 hover:bg-gray-50'}`}
              onClick={() => setViewMode('GroupView')}
            >
              群組檢視
            </button>
            <button
              className={`px-3 py-1 text-sm ${viewMode === 'AddressSort' ? 'bg-blue-500 text-white' : 'bg-white text-gray-700 hover:bg-gray-50'}`}
              onClick={() => setViewMode('AddressSort')}
            >
              位址排序
            </button>
          </div>
        </div>
      )}

      {/* 暫存器列表 */}
      <div className="flex-1 overflow-auto p-4">
        {!selectedRegisterTable ? (
          <div className="text-center text-gray-500 mt-10">
            <p>請選擇產品以載入暫存器配置</p>
          </div>
        ) : filteredRegisters.length === 0 ? (
          <div className="text-center text-gray-500 mt-10">
            <p>沒有找到匹配的暫存器</p>
          </div>
        ) : viewMode === 'GroupView' ? (
          // 群組檢視 - 響應式多欄佈局 + 不同淺色背景
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {Object.entries(groupedRegisters).map(([group, registers], groupIndex) => (
              <div
                key={group}
                className={`rounded-lg border border-gray-200 overflow-hidden ${GROUP_COLORS[groupIndex % GROUP_COLORS.length]}`}
              >
                {/* 群組標題 */}
                <div className="px-3 py-2 border-b border-gray-200/50 bg-white/50">
                  <h3 className="text-sm font-semibold text-gray-700 truncate">
                    {group}
                  </h3>
                </div>
                {/* 寄存器列表 */}
                <div className="p-2 space-y-1 max-h-96 overflow-y-auto">
                  {registers.map((register, index) => (
                    <RegisterControl
                      key={`${register.Name}-${index}`}
                      register={register}
                      viewMode={viewMode}
                      onChange={handleRegisterChange}
                    />
                  ))}
                </div>
              </div>
            ))}
          </div>
        ) : (
          // 位址排序 - 顯示地址和位元範圍
          <div className="space-y-1">
            {filteredRegisters.map((register, index) => (
              <RegisterControl
                key={`${register.Name}-${index}`}
                register={register}
                viewMode={viewMode}
                onChange={handleRegisterChange}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

// 單個 Register 控制項組件
// 根據 Lua 中定義的屬性決定顯示類型：ComboBox、CheckBox 或 TextBlock
function RegisterControl({
  register,
  viewMode,
  onChange
}: {
  register: RegisterViewModel
  viewMode: 'GroupView' | 'AddressSort'
  onChange?: (reg: RegisterViewModel, value: number) => void
}) {
  // 使用 useRef 來追蹤當前值，確保 UI 正確更新
  const currentValueRef = useRef(register.DAC)
  currentValueRef.current = register.DAC

  // 判斷控制項類型（完全參考 GMT2026 的邏輯）
  // 優先級：IsCheckBox > IsTextBlock > ComboBox > NumberInput
  const isCheckBox = register.IsCheckBox === true
  const isTextBlock = register.IsTextBlock === true
  const hasDACValues = register.DACValues && register.DACValues.length > 0
  const isComboBox = !isCheckBox && !isTextBlock && hasDACValues
  const isNumberInput = !isCheckBox && !isTextBlock && !isComboBox

  // 位址排序模式下的地址位元範圍顯示
  const addressBitRange = viewMode === 'AddressSort' ? (
    <span className="w-36 text-sm font-mono text-gray-600 shrink-0">
      0x{register.Addr.toString(16).toUpperCase().padStart(2, '0')} [{register.MSB}:{register.LSB}]
    </span>
  ) : null

  // 群組模式下的名稱
  const nameDisplay = viewMode === 'GroupView' ? (
    <span className="text-sm font-medium text-gray-800 truncate min-w-0 flex-1" title={register.Name}>
      {register.Name}
    </span>
  ) : null

  // 處理值變更
  const handleValueChange = (newValue: number) => {
    register.DAC = newValue
    onChange?.(register, newValue)
  }

  // 格式化數值為人類可讀格式（參考 GMT2026，自動添加 G/M/k 前綴）
  // 小數點顯示到第3位
  const formatNumberWithPrefix = (num: number): string => {
    const absNum = Math.abs(num)

    if (absNum >= 1e9) {
      // Giga (G) - 10億
      const val = num / 1e9
      return val % 1 === 0 ? `${val} G` : `${val.toFixed(3).replace(/\.?0+$/, '')} G`
    } else if (absNum >= 1e6) {
      // Mega (M) - 百萬
      const val = num / 1e6
      return val % 1 === 0 ? `${val} M` : `${val.toFixed(3).replace(/\.?0+$/, '')} M`
    } else if (absNum >= 1e3) {
      // kilo (k) - 千
      const val = num / 1e3
      return val % 1 === 0 ? `${val} k` : `${val.toFixed(3).replace(/\.?0+$/, '')} k`
    } else {
      // 小於 1000：顯示到小數點第3位
      return num.toFixed(3).replace(/\.?0+$/, '')
    }
  }

  // 格式化顯示值
  const formatValue = (value: string | number): string => {
    // 如果是文字，直接返回
    if (typeof value === 'string') {
      // 如果是數字文字，先嘗試格式化為人類可讀格式
      const numValue = parseFloat(value)
      if (!isNaN(numValue)) {
        const formatted = formatNumberWithPrefix(numValue)
        return register.Unit ? `${formatted} ${register.Unit}` : formatted
      }
      return register.Unit ? `${value} ${register.Unit}` : value
    }

    // 數值格式化：自動判斷顯示格式
    const formatted = formatNumberWithPrefix(value)
    return register.Unit ? `${formatted} ${register.Unit}` : formatted
  }

  return (
    <div className="flex items-center p-1.5 bg-white rounded border border-gray-200 shadow-sm hover:shadow-md transition-shadow">
      {/* 位址和 bit 範圍（僅在位址排序模式下顯示） */}
      {addressBitRange}

      {/* 名稱 */}
      {nameDisplay}

      {/* 值控制項 - 根據屬性決定類型 */}
      <div className="flex-1 min-w-0">
        {/* CheckBox：當 IsCheckBox=true 時使用 */}
        {isCheckBox && (
          <div className="flex items-center space-x-3">
            <label className="flex items-center space-x-1 cursor-pointer">
              <input
                type="radio"
                name={`${register.Name}_checkbox`}
                value={0}
                checked={currentValueRef.current === 0}
                onChange={() => handleValueChange(0)}
                disabled={register.ReadOnly}
                className="w-4 h-4 text-blue-600"
              />
              <span className="text-xs text-gray-700">Off</span>
            </label>
            <label className="flex items-center space-x-1 cursor-pointer">
              <input
                type="radio"
                name={`${register.Name}_checkbox`}
                value={1}
                checked={currentValueRef.current === 1}
                onChange={() => handleValueChange(1)}
                disabled={register.ReadOnly}
                className="w-4 h-4 text-blue-600"
              />
              <span className="text-xs text-gray-700">On</span>
            </label>
          </div>
        )}

        {/* ComboBox：當有 DACValues 且不是 CheckBox/TextBlock 時使用 */}
        {isComboBox && (
          <select
            className="w-full px-2 py-1 text-xs border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-blue-500 bg-white cursor-pointer"
            value={currentValueRef.current}
            onChange={(e) => {
              const newValue = parseInt(e.target.value, 10)
              if (!isNaN(newValue)) {
                handleValueChange(newValue)
              }
            }}
            disabled={register.ReadOnly}
          >
            {register.DACValues?.map((value, idx) => (
              <option key={idx} value={idx}>
                {formatValue(value)}
              </option>
            ))}
          </select>
        )}

        {/* TextBlock：只讀文字區塊 */}
        {isTextBlock && (
          <div className="w-full px-2 py-1 text-xs border border-gray-300 rounded bg-gray-100 text-gray-600">
            {register.CurrentValue ?? register.DAC ?? ''}
          </div>
        )}

        {/* Number Input：沒有 DACValues 且不是 CheckBox/TextBlock 時使用 */}
        {isNumberInput && (
          <input
            type="text"
            className="w-full px-2 py-1 text-xs border border-gray-300 rounded font-mono focus:outline-none focus:ring-1 focus:ring-blue-500"
            value={`0x${(currentValueRef.current ?? 0).toString(16).toUpperCase()}`}
            onChange={(e) => {
              const value = e.target.value
              let newValue: number
              if (value.startsWith('0x') || value.startsWith('0X')) {
                newValue = parseInt(value.substring(2), 16)
              } else {
                newValue = parseInt(value, 10)
              }
              if (!isNaN(newValue)) {
                handleValueChange(newValue)
              }
            }}
            readOnly={register.ReadOnly}
          />
        )}
      </div>

      {/* 只讀標記 */}
      {register.ReadOnly && (
        <span className="text-xs text-gray-400 bg-gray-100 px-1.5 py-0.5 rounded ml-1 shrink-0">
          只讀
        </span>
      )}
    </div>
  )
}
