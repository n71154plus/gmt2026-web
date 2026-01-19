'use client'

import { useState, useEffect } from 'react'
import { TitleBar } from './TitleBar'
import { MenuBar } from './MenuBar'
import { StatusBar } from './StatusBar'
import { LeftPanel } from './LeftPanel'
import { MainContent } from './MainContent'
import { AppState, ProductFileInfo } from '@/types'

export function MainWindow() {
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

  // 處理產品選擇變化
  const handleProductSelect = async (product: ProductFileInfo) => {
    try {
      // 載入產品數據
      const response = await fetch(`/api/products/${product.FileName}`)
      if (response.ok) {
        const productData = await response.json()
        // 這裡應該解析產品數據並設置 registerTables
        // 目前使用模擬數據
        const mockRegisterTables = [
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
                IsTextBlock: false,
                CurrentValue: 0,
                DACValues: ['Disable', '1us', '1.5us', '2us', '2.5us', '3us', '3.5us', '4us'],
                IsCheckBox: false,
                AddressColorIndex: 0
              }
            ],
            Data: [],
            Pages: ['Page 1'],
            SelectedPage: 'Page 1',
            ViewMode: 'GroupView' as const,
            FilterText: '',
            RegistersView: [],
            CheckSumCollection: {}
          }
        ]

        updateAppState({
          selectedProduct: product,
          registerTables: mockRegisterTables,
          selectedRegisterTable: undefined,
          selectedAddress: undefined,
          deviceAddressesView: [
            { RegisterTableName: 'Default', Value: 0x5E }
          ]
        })
      }
    } catch (error) {
      console.error('載入產品數據失敗:', error)
    }
  }

  const updateAppState = (updates: Partial<AppState>) => {
    setAppState(prev => ({ ...prev, ...updates }))
  }

  return (
    <div className="h-screen flex flex-col bg-gray-100">
      {/* 自訂標題列 */}
      <TitleBar
        title={appState.title}
        modelName={appState.modelName}
        onModelNameChange={(modelName) => updateAppState({ modelName })}
      />

      {/* 選單列 */}
      <MenuBar />

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
        {/* 左側面板 */}
        <LeftPanel
          availableProducts={appState.availableProducts}
          selectedProduct={appState.selectedProduct}
          deviceAddressesView={appState.deviceAddressesView}
          selectedAddress={appState.selectedAddress}
          isI2cBusy={appState.isI2cBusy}
          onProductSelect={handleProductSelect}
          onAddressSelect={(address) => updateAppState({ selectedAddress: address })}
        />

        {/* 右側主要內容 */}
        <MainContent
          selectedRegisterTable={appState.selectedRegisterTable}
          registerTables={appState.registerTables}
          onRegisterTableSelect={(table) => updateAppState({ selectedRegisterTable: table })}
        />
      </div>
    </div>
  )
}