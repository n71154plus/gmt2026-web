interface TitleBarProps {
  title: string
  modelName: string
  onModelNameChange: (modelName: string) => void
  onMenuToggle?: () => void
  isMobile?: boolean
}

export function TitleBar({ title, modelName, onModelNameChange, onMenuToggle, isMobile }: TitleBarProps) {
  return (
    <div className="h-8 bg-blue-600 flex items-center px-2">
      {/* 行動裝置選單按鈕 */}
      {isMobile && onMenuToggle && (
        <button
          onClick={onMenuToggle}
          className="w-8 h-8 flex items-center justify-center text-white hover:bg-blue-500 rounded mr-2"
        >
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
      )}

      <span className="text-white font-semibold text-sm flex-1 ml-2">
        {title}
      </span>

      {/* 機種名稱輸入 - 桌面端顯示 */}
      {!isMobile && (
        <input
          type="text"
          value={modelName}
          onChange={(e) => onModelNameChange(e.target.value)}
          className="px-2 py-1 text-sm w-48 mr-2 bg-white border border-gray-300 rounded"
          placeholder="機種名稱"
        />
      )}

      {/* 視窗控制按鈕 - 桌面端顯示 */}
      {!isMobile && (
        <div className="flex space-x-1">
          <button className="w-8 h-6 bg-blue-500 hover:bg-blue-400 text-white text-xs">−</button>
          <button className="w-8 h-6 bg-blue-500 hover:bg-blue-400 text-white text-xs">□</button>
          <button className="w-8 h-6 bg-red-500 hover:bg-red-400 text-white text-xs">×</button>
        </div>
      )}
    </div>
  )
}
