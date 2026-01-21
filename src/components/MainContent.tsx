'use client'

import { useState, useCallback, useMemo, useRef, useEffect } from 'react'
import { RegisterTableViewModel, RegisterViewModel, Register } from '@/types'
import { DataBits } from '@/lib/dataBits'
import { ConcreteRegisterViewModel } from '@/types/concreteRegisterViewModel'
import { BitSegmentImpl } from '@/lib/bitSegment'
import ByteGrid from './ByteGrid'

interface MainContentProps {
  selectedRegisterTable?: RegisterTableViewModel
  registerTables: RegisterTableViewModel[]
  onRegisterTableSelect: (table: RegisterTableViewModel) => void
  onRecalculateDAC?: (regName: string, parameters: Record<string, number>) => Promise<(string | number)[]>
  onRegisterChange?: (registerViewModels?: ConcreteRegisterViewModel[], fallbackTables?: any[]) => void
  viewMode?: 'GroupView' | 'AddressSort'
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
  onRecalculateDAC,
  onRegisterChange,
  viewMode: externalViewMode
}: MainContentProps) {
  const [filterText, setFilterText] = useState('')
  const [internalViewMode, setInternalViewMode] = useState<'GroupView' | 'AddressSort'>('GroupView')
  const viewMode = externalViewMode ?? internalViewMode
  // 使用 forceUpdate 來強制重新渲染
  const [, setForceUpdate] = useState(0)

  // 使用 ref 來追蹤是否正在初始化 DataBits（避免循環更新）
  const isInitializingDataBits = useRef(false)
  // 使用 ref 來追蹤初始化計時器
  const initTimeoutRef = useRef<NodeJS.Timeout | null>(null);

  // 使用 ref 來追蹤當前的 RegisterTable，避免依賴 state
  const registerTableRef = useRef<RegisterTableViewModel | null>(null);
  // 使用 ref 來存儲最新的 onRegisterChange 回調
  const onRegisterChangeRef = useRef(onRegisterChange);
  // 更新 ref
  useEffect(() => {
    onRegisterChangeRef.current = onRegisterChange;
  }, [onRegisterChange]);

  // 創建 DataBits 實例 - 使用 ref 確保實例穩定
  const dataBitsRef = useRef<DataBits | null>(null);
  const getCurrentDataBits = useCallback(() => dataBitsRef.current, []);

  // 使用 ref 來存儲 registerViewModels，避免循環依賴
  const registerViewModelsRef = useRef<ConcreteRegisterViewModel[]>([]);

  // 標記是否正在重新計算 DACValues，避免重複觸發
  const isRecalculatingDACValues = useRef(false);

  // 創建 dataMutated 回調 - 不依賴外部 callback，避免每次渲染都重新創建
  const dataMutatedCallback = useCallback((vm: ConcreteRegisterViewModel) => {
    // 如果正在初始化 DataBits，完全跳過這個回調
    if (isInitializingDataBits.current) {
      return;
    }

    // 當 RegisterViewModel 變化時，更新 RegisterTable 的數據
    const currentRegisterTable = registerTableRef.current;
    const currentDataBits = dataBitsRef.current;

    if (!currentRegisterTable || !currentDataBits) return;

    let hasChanges = false;

    // 更新所有受影響的位元組
    vm.byteIndicesList.forEach(address => {
      const byteValue = currentDataBits.getByte(address);
      const existingData = currentRegisterTable.Data.find(d => d.Address === address);
      if (existingData) {
        if (existingData.Bytes[0] !== byteValue) {
          existingData.Bytes[0] = byteValue;
          hasChanges = true;
        }
      } else {
        currentRegisterTable.Data.push({
          Address: address,
          Bytes: [byteValue]
        });
        hasChanges = true;
      }
    });
  }, []); // 不依賴任何變量，使用 ref 訪問最新值

  const dataBits = useMemo(() => {
    if (!selectedRegisterTable) {
      dataBitsRef.current = null;
      return null;
    }

    // 如果已經有實例且 RegisterTable 沒有重大變化，保持現有實例
    // 使用引用比較來避免不必要的重新創建
    if (dataBitsRef.current &&
        dataBitsRef.current.byteCount >= Math.max(...selectedRegisterTable.NeedShowMemIndex, 0) + 1) {
      return dataBitsRef.current;
    }

    // 創建新的實例
    const byteCount = Math.max(...selectedRegisterTable.NeedShowMemIndex, 255) + 1;
    const bytes = new Uint8Array(byteCount);

    // 從現有數據填充
    selectedRegisterTable.Data.forEach(dataItem => {
      if (dataItem.Address < byteCount && dataItem.Bytes.length > 0) {
        bytes[dataItem.Address] = dataItem.Bytes[0];
      }
    });

    const newBits = new DataBits(bytes);
    dataBitsRef.current = newBits;
    return newBits;
  }, [selectedRegisterTable]);

  // 更新 registerTableRef
  useEffect(() => {
    registerTableRef.current = selectedRegisterTable ?? null;
  }, [selectedRegisterTable]);

  // 創建 RegisterViewModel 實例（不依賴 dataBits）
  const registerViewModels = useMemo(() => {
    if (!selectedRegisterTable) return [];

    return selectedRegisterTable.Registers.map(register => {
      // 轉換 Register 為包含 BitSegment 的格式
      const enhancedRegister: Register = {
        ...register,
        MemI_B0: BitSegmentImpl.fromAddrMsbLsb(register.Addr, register.MSB, register.LSB),
        BitLength: register.MSB - register.LSB + 1,
        ValuesCount: register.ValuesCount || Math.pow(2, register.MSB - register.LSB + 1)
      };

      // 先創建 RegisterViewModel，但暫時不綁定 dataBits
      const vm = new ConcreteRegisterViewModel(enhancedRegister, null as any, dataMutatedCallback);

      return vm;
    });
  }, [selectedRegisterTable, dataMutatedCallback]);

  // 更新 registerViewModelsRef
  useEffect(() => {
    registerViewModelsRef.current = registerViewModels;
  }, [registerViewModels]);

  // 當 RegisterViewModel 第一次準備好時，觸發規則評估
  const hasInitializedRules = useRef(false);
  useEffect(() => {
    if (registerViewModels.length > 0 && onRegisterChange && !hasInitializedRules.current) {
      hasInitializedRules.current = true;
      onRegisterChange(registerViewModels);
    }
  }, [registerViewModels.length, onRegisterChange]);

  // 單獨綁定 dataBits，避免循環依賴
  useEffect(() => {
    if (!dataBits || registerViewModels.length === 0) return;

    // 設置初始化標誌，避免循環更新
    isInitializingDataBits.current = true;

    // 清除之前的計時器
    if (initTimeoutRef.current) {
      clearTimeout(initTimeoutRef.current);
    }

    registerViewModels.forEach(vm => {
      vm.rebindDataBits(dataBits);
    });

    // 延遲一段時間讓 ByteGrid 有時間處理所有事件，然後清除初始化標誌
    initTimeoutRef.current = setTimeout(() => {
      isInitializingDataBits.current = false;
      initTimeoutRef.current = null;
    }, 500);

    return () => {
      // 清理計時器
      if (initTimeoutRef.current) {
        clearTimeout(initTimeoutRef.current);
        initTimeoutRef.current = null;
      }
    };
  }, [dataBits, registerViewModels]);

  // 過濾的 RegisterViewModel
  const filteredRegisterViewModels = registerViewModels.filter(vm => {
    if (!filterText) return true
    const searchText = filterText.toLowerCase()
    return vm.name.toLowerCase().includes(searchText) ||
           vm.group.toLowerCase().includes(searchText) ||
           vm.memI_B0Addr.toString(16).toLowerCase().includes(searchText)
  })

  // 分組顯示 (群組檢視) - 按 Group 分組
  const groupedRegisterViewModels = useMemo(() => {
    return filteredRegisterViewModels.reduce((groups, vm) => {
      const group = vm.group
      if (!groups[group]) groups[group] = []
      groups[group].push(vm)
      return groups
    }, {} as Record<string, ConcreteRegisterViewModel[]>)
  }, [filteredRegisterViewModels])

  // 注意：我們不再在dataBits變化時自動更新RegisterTable.Data
  // 因為RegisterViewModel的dataMutated回調已經處理了這個邏輯
  // 這樣避免了重複更新

  // 強制重新渲染
  const forceRerender = useCallback(() => {
    setForceUpdate(prev => prev + 1)
  }, [])

  // 處理 RegisterViewModel 值變更
  const handleRegisterViewModelChange = useCallback((vm: ConcreteRegisterViewModel, newValue: number) => {
    // console.log(`[handleRegisterViewModelChange] ${vm.name} value changed to: ${newValue}`)

    // 記錄舊值
    const oldDac = vm.dac;

    // RegisterViewModel 的 DAC setter 會自動處理數據位元更新
    vm.dac = newValue

    // 如果值沒有改變，不需要進行後續處理
    if (oldDac === newValue) {
      return;
    }

    // console.log(`[handleRegisterViewModelChange] After setting, ${vm.name}.dac = ${vm.dac}`)

    // 收集需要重新計算的寄存器
    const recalculationPromises: Promise<void>[] = []

    // 檢查哪些寄存器依賴於此寄存器
    if (selectedRegisterTable && onRecalculateDAC) {
      registerViewModels.forEach(r => {
        let dependsOnThis = false
        let externalParams: Record<string, number> = {}

        // 檢查 DACValueExpr 中的變數引用
        if (r.rawRegister.DACValueExpr) {
          // 檢查是否包含當前寄存器的值引用，如 [Switching_Frequency_Value]
          const valueRefPattern = new RegExp(`\\[${vm.name}_Value\\]`, 'i')
          dependsOnThis = valueRefPattern.test(r.rawRegister.DACValueExpr)

          if (dependsOnThis) {
            // 構建所有當前寄存器表中寄存器的 DAC 參數
            registerViewModels.forEach(paramReg => {
              externalParams[`${paramReg.name}_DAC`] = paramReg.dac
            })
          }
        }

        if (dependsOnThis) {
          // 收集重新計算的 Promise
          const recalculationPromise = (async () => {
            try {
              const newDACValues = await onRecalculateDAC(r.name, externalParams)
              r.rawRegister.DACValues = newDACValues
              console.log(`Recalculated DACValues for ${r.name}:`, newDACValues)
            } catch (error) {
              console.error(`Failed to recalculate DACValues for ${r.name}:`, error)
            }
          })()
          recalculationPromises.push(recalculationPromise)
        }
      })
    }

    // 等待所有 DACValues 重新計算完成，然後觸發規則評估
    const triggerRuleEvaluation = async () => {
      if (recalculationPromises.length > 0) {
        console.log(`Waiting for ${recalculationPromises.length} DAC recalculations to complete...`)
        await Promise.all(recalculationPromises)
        console.log('All DAC recalculations completed')
      }

      // 觸發規則重新評估
      if (onRegisterChange) {
        // console.log('Register changed, triggering rule evaluation...')
        onRegisterChange()
      }
    }

    triggerRuleEvaluation()
  }, [selectedRegisterTable, registerViewModels, onRecalculateDAC, forceRerender, onRegisterChange])

  return (
    <div className="flex-1 flex flex-col bg-white">
      {/* Byte Grid - 放在一個帶邊框的容器中 */}
      {dataBits && (
        <div className="border border-gray-300 rounded bg-white mb-2 shrink-0">
          <ByteGrid
            dataBits={dataBits}
            visibleIndices={selectedRegisterTable?.NeedShowMemIndex}
            headerFormat="0x{0:X2}"
            onByteChanged={(index, value) => {
              // 如果正在初始化 DataBits，完全跳過這個回調
              // 這樣可以避免在初始化期間觸發任何外部更新
              if (isInitializingDataBits.current) {
                return;
              }

              // 只在非初始化期間記錄日誌
              console.log(`Byte at address 0x${index.toString(16)} changed to: 0x${value.toString(16).padStart(2, '0')}`);

              // 觸發規則評估
              onRegisterChange?.();
            }}
          />
          </div>
      )}

      {/* 過濾器 - 只有在 AddressSort 模式時才顯示 */}
      {selectedRegisterTable && viewMode === 'AddressSort' && (
        <div className="mb-2 p-2 bg-white border border-gray-300 rounded shrink-0">
          <div className="flex items-center">
            <span className="text-sm font-medium text-gray-700 mr-2 shrink-0">過濾：</span>
          <input
            type="text"
            value={filterText}
            onChange={(e) => setFilterText(e.target.value)}
            placeholder="輸入名稱、群組或地址..."
              className="flex-1 px-2 py-1 text-sm border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-blue-500"
          />
          </div>
        </div>
      )}

      {/* 暫存器列表 */}
      <div className="flex-1 overflow-auto p-2">
        {!selectedRegisterTable ? (
          <div className="text-center text-gray-500 mt-10">
            <p>請選擇產品以載入暫存器配置</p>
          </div>
        ) : filteredRegisterViewModels.length === 0 ? (
          <div className="text-center text-gray-500 mt-10">
            <p>沒有找到匹配的暫存器</p>
          </div>
        ) : viewMode === 'GroupView' ? (
          // 群組檢視 - 響應式多欄佈局 + 不同淺色背景
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
            {Object.entries(groupedRegisterViewModels).map(([group, registerViewModels], groupIndex) => (
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
                  {registerViewModels
                    .filter(vm => vm.group === group)
                    .map((vm, index) => (
                    <RegisterControl
                        key={`${vm.name}-${index}`}
                        registerViewModel={vm}
                      viewMode={viewMode}
                        onChange={(vm, value) => {
                          // 使用新的 RegisterViewModel
                          handleRegisterViewModelChange(vm, value);
                        }}
                    />
                  ))}
                </div>
              </div>
            ))}
          </div>
        ) : (
          // 位址排序 - 顯示地址和位元範圍
          <div className="space-y-1">
            {filteredRegisterViewModels.map((vm, index) => (
              <RegisterControl
                key={`${vm.name}-${index}`}
                registerViewModel={vm}
                viewMode={viewMode}
                onChange={handleRegisterViewModelChange}
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
  registerViewModel,
  viewMode,
  onChange
}: {
  registerViewModel: ConcreteRegisterViewModel
  viewMode: 'GroupView' | 'AddressSort'
  onChange?: (vm: ConcreteRegisterViewModel, value: number) => void
}) {
  // 使用 useRef 來追蹤當前值，確保 UI 正確更新
  const currentValueRef = useRef(registerViewModel.dac)
  currentValueRef.current = registerViewModel.dac

  // 判斷控制項類型（完全參考 GMT2026 的邏輯）
  // 優先級：IsCheckBox > IsTextBlock > ComboBox > NumberInput
  const isCheckBox = registerViewModel.isCheckBox
  const isTextBlock = registerViewModel.rawRegister.IsTextBlock === true
  const hasDACValues = registerViewModel.dacValues && registerViewModel.dacValues.length > 0
  const isComboBox = !isCheckBox && !isTextBlock && hasDACValues
  const isNumberInput = !isCheckBox && !isTextBlock && !isComboBox

  // 位址排序模式下的地址位元範圍顯示
  const addressBitRange = viewMode === 'AddressSort' ? (
    <span className="w-36 text-sm font-mono text-gray-600 shrink-0">
      {registerViewModel.addressBitRange}
    </span>
  ) : null

  // 群組模式下的名稱
  const nameDisplay = viewMode === 'GroupView' ? (
    <span className="text-sm font-medium text-gray-800 truncate min-w-0 flex-1" title={registerViewModel.name}>
      {registerViewModel.name}
    </span>
  ) : null

  // 處理值變更
  const handleValueChange = (newValue: number) => {
    registerViewModel.dac = newValue
    // 延遲一點時間再觸發規則評估，確保狀態穩定
    setTimeout(() => {
      onChange?.(registerViewModel, newValue)
    }, 50)
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
        return registerViewModel.unit ? `${formatted} ${registerViewModel.unit}` : formatted
      }
      return registerViewModel.unit ? `${value} ${registerViewModel.unit}` : value
    }

    // 數值格式化：自動判斷顯示格式
    const formatted = formatNumberWithPrefix(value)
    return registerViewModel.unit ? `${formatted} ${registerViewModel.unit}` : formatted
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
                name={`${registerViewModel.name}_checkbox`}
                value={0}
                checked={currentValueRef.current === 0}
                onChange={() => handleValueChange(0)}
                disabled={registerViewModel.isReadOnly}
                className="w-4 h-4 text-blue-600"
              />
              <span className="text-xs text-gray-700">Off</span>
            </label>
            <label className="flex items-center space-x-1 cursor-pointer">
              <input
                type="radio"
                name={`${registerViewModel.name}_checkbox`}
                value={1}
                checked={currentValueRef.current === 1}
                onChange={() => handleValueChange(1)}
                disabled={registerViewModel.isReadOnly}
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
            disabled={registerViewModel.isReadOnly}
          >
            {registerViewModel.dacValues?.map((value, idx) => (
              <option key={idx} value={idx}>
                {formatValue(value)}
              </option>
            ))}
          </select>
        )}

        {/* TextBlock：只讀文字區塊 */}
        {isTextBlock && (
          <div className="w-full px-2 py-1 text-xs border border-gray-300 rounded bg-gray-100 text-gray-600">
            {registerViewModel.displayValue ?? currentValueRef.current ?? ''}
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
            readOnly={registerViewModel.isReadOnly}
          />
        )}
      </div>

      {/* 只讀標記 */}
      {registerViewModel.isReadOnly && (
        <span className="text-xs text-gray-400 bg-gray-100 px-1.5 py-0.5 rounded ml-1 shrink-0">
          只讀
        </span>
      )}
    </div>
  )
}
