'use client'

import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  Filler
} from 'chart.js'
import { Line, Bar, Doughnut } from 'react-chartjs-2'

// 註冊 Chart.js 組件
ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  Title,
  Tooltip,
  Legend,
  ArcElement,
  Filler
)

// 圖表數據類型
export interface ChartData {
  labels: string[]
  datasets: {
    label: string
    data: number[]
    borderColor?: string
    backgroundColor?: string | string[]
    fill?: boolean
    tension?: number
  }[]
}

// 折線圖組件
interface LineChartProps {
  data: ChartData
  title?: string
  height?: number
}

export function LineChart({ data, title, height = 300 }: LineChartProps) {
  const chartData = {
    labels: data.labels,
    datasets: data.datasets.map((dataset, index) => ({
      ...dataset,
      borderColor: dataset.borderColor || getDefaultColor(index),
      backgroundColor: dataset.backgroundColor || getDefaultColorWithAlpha(index),
      fill: dataset.fill ?? true,
      tension: dataset.tension ?? 0.4
    }))
  }

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'top' as const
      },
      title: {
        display: !!title,
        text: title
      }
    },
    scales: {
      y: {
        beginAtZero: true
      }
    }
  }

  return (
    <div style={{ height: `${height}px` }}>
      <Line data={chartData} options={options} />
    </div>
  )
}

// 柱狀圖組件
interface BarChartProps {
  data: ChartData
  title?: string
  height?: number
  horizontal?: boolean
}

export function BarChart({ data, title, height = 300, horizontal = false }: BarChartProps) {
  const chartData = {
    labels: data.labels,
    datasets: data.datasets.map((dataset, index) => ({
      ...dataset,
      backgroundColor: dataset.backgroundColor || getBarColor(index)
    }))
  }

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    indexAxis: horizontal ? 'y' as const : 'x' as const,
    plugins: {
      legend: {
        display: false
      },
      title: {
        display: !!title,
        text: title
      }
    }
  }

  return (
    <div style={{ height: `${height}px` }}>
      <Bar data={chartData} options={options} />
    </div>
  )
}

// 環形圖組件
interface DoughnutChartProps {
  data: ChartData
  title?: string
  height?: number
}

export function DoughnutChart({ data, title, height = 300 }: DoughnutChartProps) {
  const chartData = {
    labels: data.labels,
    datasets: [{
      data: data.datasets[0]?.data || [],
      backgroundColor: data.datasets[0]?.backgroundColor || [
        'rgba(54, 162, 235, 0.8)',
        'rgba(255, 99, 132, 0.8)',
        'rgba(255, 206, 86, 0.8)',
        'rgba(75, 192, 192, 0.8)',
        'rgba(153, 102, 255, 0.8)',
        'rgba(255, 159, 64, 0.8)'
      ],
      borderColor: '#fff',
      borderWidth: 2
    }]
  }

  const options = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'right' as const
      },
      title: {
        display: !!title,
        text: title
      }
    }
  }

  return (
    <div style={{ height: `${height}px` }}>
      <Doughnut data={chartData} options={options} />
    </div>
  )
}

// 默認顏色
function getDefaultColor(index: number): string {
  const colors = [
    'rgba(54, 162, 235, 1)',
    'rgba(255, 99, 132, 1)',
    'rgba(255, 206, 86, 1)',
    'rgba(75, 192, 192, 1)',
    'rgba(153, 102, 255, 1)',
    'rgba(255, 159, 64, 1)'
  ]
  return colors[index % colors.length]
}

function getDefaultColorWithAlpha(index: number): string {
  return getDefaultColor(index).replace('1)', '0.2)')
}

function getBarColor(index: number): string {
  const colors = [
    'rgba(54, 162, 235, 0.8)',
    'rgba(255, 99, 132, 0.8)',
    'rgba(255, 206, 86, 0.8)',
    'rgba(75, 192, 192, 0.8)',
    'rgba(153, 102, 255, 0.8)',
    'rgba(255, 159, 64, 0.8)'
  ]
  return colors[index % colors.length]
}

// 導出圖表類型
export type { LineChartProps, BarChartProps, DoughnutChartProps }
