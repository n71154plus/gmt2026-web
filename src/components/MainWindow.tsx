'use client'

import { useState, useEffect, useCallback } from 'react'
import { TitleBar } from './TitleBar'
import { MenuBar } from './MenuBar'
import { StatusBar } from './StatusBar'
import { LeftPanel } from './LeftPanel'
import { MainContent } from './MainContent'
import { ChartPanel } from './ChartPanel'
import { AppState, ProductFileInfo, RegisterViewModel, RuleResult } from '@/types'

export function MainWindow() {
  const [activeTab, setActiveTab] = useState<'registers' | 'chart'>('registers')
  const [isMobile, setIsMobile] = useState(false)
  const [isLeftPanelOpen, setIsLeftPanelOpen] = useState(true)
  const [viewMode, setViewMode] = useState<'GroupView' | 'AddressSort'>('GroupView')

  const [appState, setAppState] = useState<AppState>({
    title: 'GMT I2C Tool',
    modelName: '',
    registerTables: [],
    deviceAddressesView: [],
    availableProducts: [],
    i2cOperationRecords: [],
    ruleResults: [],
    statusMessageColor: 'text-blue-600',
    hasStatusMessage: false,
    isI2cBusy: false,
    hasI2CErrorMessage: false,
    hasLuaErrorMessage: false,
  })

  // 檢測螢幕大小
  useEffect(() => {
    const checkScreenSize = () => {
      setIsMobile(window.innerWidth < 768)
      if (window.innerWidth < 768) {
        setIsLeftPanelOpen(false)
      } else {
        setIsLeftPanelOpen(true)
      }
    }

    checkScreenSize()
    window.addEventListener('resize', checkScreenSize)
    return () => window.removeEventListener('resize', checkScreenSize)
  }, [])

  // 載入可用的產品列表
  useEffect(() => {
    const loadAvailableProducts = async () => {
      try {
        const response = await fetch('/api/products')
        if (response.ok) {
          const products = await response.json()
          setAppState(prev => ({
            ...prev,
            availableProducts: products
          }))
        }
      } catch (error) {
        console.error('載入產品列表失敗:', error)
      }
    }

    loadAvailableProducts()
  }, [])

  // 處理未捕獲的錯誤（特別是 WebAssembly 相關的錯誤）
  useEffect(() => {
    const handleUnhandledRejection = (event: PromiseRejectionEvent) => {
      // 檢查是否是 wasmoon/WebAssembly 相關的權限錯誤
      if (event.reason && typeof event.reason === 'object') {
        const error = event.reason as any
        if (error.code === 403 && error.msg === 'permission error' && error.name === 'n') {
          // 這是已知的 WebAssembly 權限錯誤，不影響功能，抑制它
          console.warn('WebAssembly permission error suppressed (non-critical)')
          event.preventDefault()
          return
        }
      }

      // 對於其他錯誤，仍然記錄但不阻止預設行為
      console.error('Unhandled promise rejection:', event.reason)
    }

    const handleError = (event: ErrorEvent) => {
      // 可以添加其他全域錯誤處理邏輯
      console.error('Global error:', event.error)
    }

    window.addEventListener('unhandledrejection', handleUnhandledRejection)
    window.addEventListener('error', handleError)

    return () => {
      window.removeEventListener('unhandledrejection', handleUnhandledRejection)
      window.removeEventListener('error', handleError)
    }
  }, [])

  // 當選擇地址變化時，自動選擇對應的暫存器表
  useEffect(() => {
    if (appState.selectedAddress !== undefined && appState.registerTables.length > 0) {
      const selectedTable = appState.registerTables.find(table =>
        table.DeviceAddress.includes(appState.selectedAddress!)
      )
      if (selectedTable) {
        updateAppState({ selectedRegisterTable: selectedTable })
      }
    }
  }, [appState.selectedAddress, appState.registerTables])

  // 讀取記憶體數據
  const readRegisters = useCallback(async () => {
    if (!appState.selectedRegisterTable || !appState.selectedAddress) {
      console.log('readRegisters: 沒有選擇寄存器表或設備地址')
      return
    }

    console.log('開始讀取記憶體數據...')
    updateAppState({ isI2cBusy: true })

    try {
      // 模擬 I2C 讀取操作
      await new Promise(resolve => setTimeout(resolve, 1000)) // 模擬延遲

      // 更新 Byte Data（模擬從設備讀取的數據）
      const updatedData = appState.selectedRegisterTable.NeedShowMemIndex.map(address => ({
        Address: address,
        Bytes: [Math.floor(Math.random() * 256)] // 隨機生成 0-255 的值
      }))

      // 更新選中的 RegisterTable 的 Data
      const updatedRegisterTables = appState.registerTables.map(table => {
        if (table.Name === appState.selectedRegisterTable?.Name) {
          return {
            ...table,
            Data: updatedData
          }
        }
        return table
      })

      updateAppState({
        registerTables: updatedRegisterTables,
        selectedRegisterTable: updatedRegisterTables.find(t => t.Name === appState.selectedRegisterTable?.Name)
      })

      console.log('記憶體數據讀取完成')
    } catch (error) {
      console.error('讀取記憶體數據失敗:', error)
    } finally {
      updateAppState({ isI2cBusy: false })
    }
  }, [appState.selectedRegisterTable, appState.selectedAddress, appState.registerTables])

  // 寫入記憶體數據
  const writeRegisters = useCallback(async () => {
    if (!appState.selectedRegisterTable || !appState.selectedAddress) {
      console.log('writeRegisters: 沒有選擇寄存器表或設備地址')
      return
    }

    console.log('開始寫入記憶體數據...')
    updateAppState({ isI2cBusy: true })

    try {
      // 模擬 I2C 寫入操作
      await new Promise(resolve => setTimeout(resolve, 1000)) // 模擬延遲

      console.log('記憶體數據寫入完成')
    } catch (error) {
      console.error('寫入記憶體數據失敗:', error)
    } finally {
      updateAppState({ isI2cBusy: false })
    }
  }, [appState.selectedRegisterTable, appState.selectedAddress])

  // 重新計算 DAC Values（用於處理參數依賴）
  const recalculateDAC = useCallback(async (
    regName: string,
    parameters: Record<string, number>
  ): Promise<(string | number)[]> => {
    try {
      const response = await fetch('/api/products/recalculate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          regName,
          parameters,
          filename: appState.selectedProduct?.FileName,
          currentRegisters: appState.registerTables.flatMap(rt => rt.Registers)
        })
      })

      if (response.ok) {
        const data = await response.json()
        return data.dacValues || []
      }
    } catch (error) {
      console.error('重新計算 DAC 值失敗:', error)
    }
    return []
  }, [appState.selectedProduct])

  // 評估規則
  const evaluateRules = useCallback(async (product: ProductFileInfo | null, registerViewModelsOrTables?: ConcreteRegisterViewModel[] | any[], fallbackRegisterTables?: any[]) => {
    if (!product?.FileName) {
      console.log('evaluateRules: 沒有選擇產品，跳過')
      return
    }


    try {
      // 構建 RegValues 表
      const regValues: Record<string, any> = {}


      const dataSource = registerViewModelsOrTables || fallbackRegisterTables;

      if (dataSource && dataSource.length > 0) {
        // 檢查第一個元素是否是 RegisterViewModel
        const firstItem = dataSource[0];
        if (firstItem && typeof firstItem === 'object' && 'dac' in firstItem) {
          // 使用 RegisterViewModel
          const registerViewModels = dataSource as ConcreteRegisterViewModel[];
          registerViewModels.forEach(rvm => {
            // 使用 RegName_Value 格式
            if (rvm.dacValues && rvm.dacValues.length > rvm.dac) {
              const value = rvm.dacValues[rvm.dac]
              regValues[`${rvm.name}_Value`] = value
            }
            regValues[`${rvm.name}_DAC`] = rvm.dac
          })
        } else {
          // 使用 registerTables（舊方式）
          const registerTables = dataSource as any[];
          registerTables.forEach(rt => {
            rt.Registers.forEach((reg: any) => {
              // 使用 RegName_Value 格式
              if (reg.DACValues && reg.DACValues.length > 0) {
                const value = reg.DACValues[reg.DAC]
                regValues[`${reg.Name}_Value`] = value
                console.log(`[evaluateRules fallback] RegValues.${reg.Name}_Value =`, value, `(DAC=${reg.DAC}, DACValues.length=${reg.DACValues.length})`)
              } else {
                console.log(`[evaluateRules fallback] RegValues.${reg.Name} has no DACValues (DAC=${reg.DAC})`)
              }
              regValues[`${reg.Name}_DAC`] = reg.DAC
            })
          })
        }
      }

      //console.log('[evaluateRules] regValues keys:', Object.keys(regValues))
      //console.log('[evaluateRules] regValues sample:', Object.fromEntries(Object.entries(regValues).slice(0, 10)))

      // 服務端直接使用 wasmoon 執行規則
      const response = await fetch('/api/products/rules', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          filename: product.FileName,
          registerValues: JSON.stringify(regValues)
        })
      })

      if (response.ok) {
        const data = await response.json()
        // console.log('規則評估結果:', data.ruleResults)
        setAppState(prev => ({
          ...prev,
          ruleResults: data.ruleResults || [],
          selectedRuleResult: data.ruleResults?.[0]
        }))
      } else {
        console.error('規則評估 API 返回錯誤:', response.status)
      }
    } catch (error) {
      console.error('評估規則失敗:', error)
    }
  }, [])

  // 處理產品選擇變化
  const handleProductSelect = async (product: ProductFileInfo) => {
    try {
      console.log('選擇產品:', product.FileName)
      const url = `/api/products/${product.FileName}`
      console.log('請求 URL:', url)
      const response = await fetch(url)
      console.log('API 響應狀態:', response.status)
      console.log('API 響應 OK:', response.ok)

      if (!response.ok) {
        console.error('API 響應錯誤:', response.status, response.statusText)
        return
      }

      const data = await response.json()
      console.log('API 返回數據 keys:', Object.keys(data))
      console.log('product:', data.product)
      console.log('RegisterTable 數量:', data.product?.RegisterTable?.length)

      if (!data.product?.RegisterTable?.length) {
        console.error('RegisterTable 為空或未定義')
        return
      }

      console.log('Registers 數量:', data.product.RegisterTable[0]?.Registers?.length)

      // 將 RegisterTable 轉換為 ViewModel 格式
      const registerTables = data.product.RegisterTable.map((table: any, idx: number) => ({
        Name: table.Name,
        DeviceAddress: table.DeviceAddress,
        Registers: table.Registers.map((reg: any, rIdx: number) => ({
          ...reg,
          CurrentValue: reg.DAC,
          DefaultDAC: reg.DAC, // 設置默認DAC值用於初始化
          IsCheckBox: false,
          AddressColorIndex: rIdx % 8,
          DependentParameters: reg.DependentParameters || []
        })),
        // 初始化 Byte Data，為每個 NeedShowMemIndex 創建對應的數據項
        Data: (table.NeedShowMemIndex || []).map(address => ({
          Address: address,
          Bytes: [0] // 初始化為 0，可以通過 I2C 讀取來更新
        })),
        Pages: ['Page 1'],
        SelectedPage: 'Page 1',
        ViewMode: 'GroupView' as const,
        FilterText: '',
        RegistersView: [],
        CheckSumCollection: table.ChecksumMemIndexCollect || {},
        NeedShowMemIndex: table.NeedShowMemIndex || []
      }))

      // 生成設備地址視圖
      const deviceAddressesView = registerTables.flatMap((table: any) =>
        table.DeviceAddress.map((addr: number) => ({
          RegisterTableName: table.Name,
          Value: addr
        }))
      )

      console.log('生成的 registerTables:', registerTables)
      console.log('設備地址:', deviceAddressesView)

      updateAppState({
        selectedProduct: product,
        modelName: data.product.Name,
        registerTables,
        selectedRegisterTable: registerTables[0],
        selectedAddress: deviceAddressesView[0]?.Value,
        deviceAddressesView,
        ruleResults: [],
        selectedRuleResult: undefined
      }, () => {
        // 狀態更新完成後的回調
        // console.log('handleProductSelect: 狀態已更新，調用 evaluateRules')
        evaluateRules(product, registerTables)
      })
    } catch (error) {
      console.error('載入產品數據失敗:', error)
      console.error('錯誤堆疊:', error instanceof Error ? error.stack : 'N/A')
    }
  }

  const updateAppState = (updates: Partial<AppState>, callback?: () => void) => {
    setAppState(prev => {
      const newState = { ...prev, ...updates }
      // 在狀態更新完成後調用回調
      if (callback) {
        // 使用 setTimeout 確保狀態已完全更新
        setTimeout(callback, 0)
      }
      return newState
    })
  }

  return (
    <div className="h-screen flex flex-col bg-gray-100">
      {/* 自訂標題列 */}
      <TitleBar
        title={appState.title}
        modelName={appState.modelName}
        onModelNameChange={(modelName) => updateAppState({ modelName })}
        onMenuToggle={() => setIsLeftPanelOpen(!isLeftPanelOpen)}
        isMobile={isMobile}
      />

      {/* 選單列 */}
      <MenuBar onViewModeChange={(mode) => setViewMode(mode)} />

      {/* 狀態列 */}
      <StatusBar
        ruleResults={appState.ruleResults}
        selectedRuleResult={appState.selectedRuleResult}
        i2cOperationRecords={appState.i2cOperationRecords}
        selectedI2COperationRecord={appState.selectedI2COperationRecord}
        statusMessage={appState.statusMessage}
        statusMessageColor={appState.statusMessageColor}
        onRuleResultSelect={(rule) => updateAppState({ selectedRuleResult: rule })}
        onI2CRecordSelect={(record) => updateAppState({ selectedI2COperationRecord: record })}
      />

      {/* 主要內容區域 */}
      <div className="flex flex-1 overflow-hidden">
        {/* 左側面板 - 響應式顯示 */}
        {isLeftPanelOpen && (
          <div className={`
            ${isMobile ? 'absolute inset-0 z-50' : 'relative'}
          `}>
            <div className="h-full bg-white border-r border-gray-300 shadow-lg flex flex-col">
              <LeftPanel
                availableProducts={appState.availableProducts}
                selectedProduct={appState.selectedProduct}
                deviceAddressesView={appState.deviceAddressesView}
                selectedAddress={appState.selectedAddress}
                isI2cBusy={appState.isI2cBusy}
                onProductSelect={handleProductSelect}
                onAddressSelect={(address) => updateAppState({ selectedAddress: address })}
                onReadRegisters={readRegisters}
                onWriteRegisters={writeRegisters}
              />
              {isMobile && (
                <button
                  onClick={() => setIsLeftPanelOpen(false)}
                  className="absolute top-2 right-2 p-2 bg-gray-200 rounded-full"
                >
                  ✕
                </button>
              )}
            </div>
          </div>
        )}

        {/* 主內容區域 */}
        <div className="flex-1 flex flex-col overflow-hidden">
          {/* 標籤切換 - 移動端顯示 */}
          {isMobile && (
            <div className="flex border-b border-gray-300 bg-white">
              <button
                onClick={() => setActiveTab('registers')}
                className={`flex-1 py-2 px-4 text-sm font-medium ${
                  activeTab === 'registers'
                    ? 'text-blue-600 border-b-2 border-blue-600'
                    : 'text-gray-600'
                }`}
              >
                暫存器
              </button>
              <button
                onClick={() => setActiveTab('chart')}
                className={`flex-1 py-2 px-4 text-sm font-medium ${
                  activeTab === 'chart'
                    ? 'text-blue-600 border-b-2 border-blue-600'
                    : 'text-gray-600'
                }`}
              >
                圖表
              </button>
            </div>
          )}

          {/* 右側主要內容 */}
          <div className="flex-1 overflow-auto relative">
            {/* 暫存器標籤 - 桌面端顯示標題 */}
            {!isMobile && (
              <div className="px-4 py-2 bg-gray-50 border-b border-gray-200">
                <span className="font-semibold text-gray-700">
                  {appState.selectedRegisterTable?.Name || '暫存器配置'}
                </span>
              </div>
            )}

            {/* 根據標籤顯示內容 */}
            {(!isMobile || activeTab === 'registers') && (
              <MainContent
                selectedRegisterTable={appState.selectedRegisterTable}
                registerTables={appState.registerTables}
                onRegisterTableSelect={(table) => updateAppState({ selectedRegisterTable: table })}
                onRecalculateDAC={recalculateDAC}
                onRegisterChange={(registerViewModels, fallbackTables) => evaluateRules(appState.selectedProduct, registerViewModels, fallbackTables)}
                viewMode={viewMode}
              />
            )}

            {/* 圖表標籤 - 僅移動端 */}
            {isMobile && activeTab === 'chart' && (
              <ChartPanel />
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
