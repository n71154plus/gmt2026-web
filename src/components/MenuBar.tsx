'use client'

import { useState } from 'react'

interface MenuBarProps {
  onViewModeChange?: (mode: 'GroupView' | 'AddressSort') => void
}

export function MenuBar({ onViewModeChange }: MenuBarProps = {}) {
  const [openMenu, setOpenMenu] = useState<string | null>(null)

  const menus = [
    {
      name: 'File',
      items: [
        { label: 'Save Hex', action: () => console.log('Save Hex') },
        { label: 'Load Hex', action: () => console.log('Load Hex') },
      ]
    },
    {
      name: 'View',
      items: [
        { label: '群組檢視', action: () => onViewModeChange?.('GroupView') },
        { label: '位址排序', action: () => onViewModeChange?.('AddressSort') },
      ]
    },
    {
      name: 'Tools',
      items: [
        { label: 'Diagrams', action: () => console.log('Diagrams') },
      ]
    },
    {
      name: 'Help',
      items: [
        { label: '開啟導覽', action: () => console.log('開啟導覽') },
      ]
    }
  ]

  return (
    <div className="h-8 bg-gray-200 border-b border-gray-300 flex">
      {menus.map((menu) => (
        <div
          key={menu.name}
          className="relative"
          onMouseLeave={(e) => {
            // 只有當滑鼠完全離開整個菜單區域時才關閉
            const rect = e.currentTarget.getBoundingClientRect()
            const x = e.clientX
            const y = e.clientY

            // 檢查滑鼠是否仍在菜單區域內
            if (x < rect.left || x > rect.right || y < rect.top || y > rect.bottom) {
              setOpenMenu(null)
            }
          }}
        >
          <button
            className="px-4 py-1 text-sm hover:bg-gray-300"
            onMouseEnter={() => setOpenMenu(menu.name)}
          >
            {menu.name}
          </button>
          {openMenu === menu.name && (
            <div className="absolute top-full left-0 bg-white border border-gray-300 shadow-lg py-1 min-w-48 z-50">
              {menu.items.map((item, index) => (
                <button
                  key={index}
                  className="w-full text-left px-4 py-1 text-sm hover:bg-gray-100"
                  onClick={() => {
                    item.action()
                    setOpenMenu(null) // 點擊後關閉菜單
                  }}
                >
                  {item.label}
                </button>
              ))}
            </div>
          )}
        </div>
      ))}
    </div>
  )
}