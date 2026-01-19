'use client'

import { useState, useEffect } from 'react'
import { TitleBar } from './TitleBar'
import { MenuBar } from './MenuBar'
import { StatusBar } from './StatusBar'
import { LeftPanel } from './LeftPanel'
import { MainContent } from './MainContent'
import { AppState } from '@/types'

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
          onProductSelect={(product) => updateAppState({ selectedProduct: product })}
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