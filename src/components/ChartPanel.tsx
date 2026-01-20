'use client'

import { useState } from 'react'
import { LineChart, BarChart, DoughnutChart, ChartData } from './ChartComponents'

// 模擬圖表數據
const generateLineChartData = (): ChartData => ({
  labels: ['0x00', '0x01', '0x02', '0x03', '0x04', '0x05', '0x06', '0x07'],
  datasets: [
    {
      label: '電壓 (V)',
      data: [3.3, 3.2, 3.1, 3.0, 2.9, 2.8, 2.7, 2.6],
      borderColor: 'rgba(54, 162, 235, 1)',
      backgroundColor: 'rgba(54, 162, 235, 0.2)',
      fill: true,
      tension: 0.4
    },
    {
      label: '電流 (mA)',
      data: [100, 120, 110, 130, 140, 125, 135, 145],
      borderColor: 'rgba(255, 99, 132, 1)',
      backgroundColor: 'rgba(255, 99, 132, 0.2)',
      fill: true,
      tension: 0.4
    }
  ]
})

const generateBarChartData = (): ChartData => ({
  labels: ['暫存器 1', '暫存器 2', '暫存器 3', '暫存器 4', '暫存器 5'],
  datasets: [
    {
      label: '數值',
      data: [45, 78, 32, 90, 56],
      backgroundColor: [
        'rgba(54, 162, 235, 0.8)',
        'rgba(255, 99, 132, 0.8)',
        'rgba(255, 206, 86, 0.8)',
        'rgba(75, 192, 192, 0.8)',
        'rgba(153, 102, 255, 0.8)'
      ]
    }
  ]
})

const generateDoughnutChartData = (): ChartData => ({
  labels: ['已完成', '進行中', '待處理', '錯誤'],
  datasets: [
    {
      label: '任務狀態',
      data: [45, 25, 20, 10],
      backgroundColor: [
        'rgba(75, 192, 192, 0.8)',
        'rgba(54, 162, 235, 0.8)',
        'rgba(255, 206, 86, 0.8)',
        'rgba(255, 99, 132, 0.8)'
      ]
    }
  ]
})

export function ChartPanel() {
  const [chartType, setChartType] = useState<'line' | 'bar' | 'doughnut'>('line')
  const [lineChartData] = useState<ChartData>(generateLineChartData())
  const [barChartData] = useState<ChartData>(generateBarChartData())
  const [doughnutChartData] = useState<ChartData>(generateDoughnutChartData())

  const getChartData = () => {
    switch (chartType) {
      case 'line':
        return lineChartData
      case 'bar':
        return barChartData
      case 'doughnut':
        return doughnutChartData
      default:
        return lineChartData
    }
  }

  const getChartComponent = () => {
    switch (chartType) {
      case 'line':
        return <LineChart data={lineChartData} title="暫存器數據趨勢" height={350} />
      case 'bar':
        return <BarChart data={barChartData} title="暫存器數值分佈" height={350} />
      case 'doughnut':
        return <DoughnutChart data={doughnutChartData} title="數據分類" height={350} />
      default:
        return null
    }
  }

  return (
    <div className="flex-1 flex flex-col bg-white p-4">
      <div className="flex items-center justify-between mb-4">
        <h2 className="text-lg font-semibold text-gray-800">數據圖表</h2>

        {/* 圖表類型選擇 */}
        <div className="flex space-x-2">
          <button
            onClick={() => setChartType('line')}
            className={`px-3 py-1 text-sm rounded ${
              chartType === 'line'
                ? 'bg-blue-500 text-white'
                : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
            }`}
          >
            折線圖
          </button>
          <button
            onClick={() => setChartType('bar')}
            className={`px-3 py-1 text-sm rounded ${
              chartType === 'bar'
                ? 'bg-blue-500 text-white'
                : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
            }`}
          >
            柱狀圖
          </button>
          <button
            onClick={() => setChartType('doughnut')}
            className={`px-3 py-1 text-sm rounded ${
              chartType === 'doughnut'
                ? 'bg-blue-500 text-white'
                : 'bg-gray-200 text-gray-700 hover:bg-gray-300'
            }`}
          >
            環形圖
          </button>
        </div>
      </div>

      {/* 圖表容器 */}
      <div className="flex-1 border border-gray-200 rounded-lg p-4">
        {getChartComponent()}
      </div>

      {/* 圖例說明 */}
      <div className="mt-4 p-3 bg-gray-50 rounded-lg">
        <h3 className="text-sm font-medium text-gray-700 mb-2">圖例說明</h3>
        <div className="grid grid-cols-2 gap-2 text-xs text-gray-600">
          <div className="flex items-center">
            <span className="w-3 h-3 bg-blue-500 rounded-full mr-2"></span>
            電壓趨勢 / 類別 1
          </div>
          <div className="flex items-center">
            <span className="w-3 h-3 bg-red-500 rounded-full mr-2"></span>
            電流趨勢 / 類別 2
          </div>
        </div>
      </div>
    </div>
  )
}
