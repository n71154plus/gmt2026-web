interface TitleBarProps {
  title: string
  modelName: string
  onModelNameChange: (modelName: string) => void
}

export function TitleBar({ title, modelName, onModelNameChange }: TitleBarProps) {
  return (
    <div className="h-8 bg-blue-600 flex items-center px-2">
      <span className="text-white font-semibold text-sm flex-1 ml-2">
        {title}
      </span>
      <input
        type="text"
        value={modelName}
        onChange={(e) => onModelNameChange(e.target.value)}
        className="px-2 py-1 text-sm w-48 mr-2 bg-white border border-gray-300"
        placeholder="機種名稱"
      />
      <div className="flex space-x-1">
        <button className="w-8 h-6 bg-blue-500 hover:bg-blue-400 text-white text-xs">−</button>
        <button className="w-8 h-6 bg-blue-500 hover:bg-blue-400 text-white text-xs">□</button>
        <button className="w-8 h-6 bg-red-500 hover:bg-red-400 text-white text-xs">×</button>
      </div>
    </div>
  )
}