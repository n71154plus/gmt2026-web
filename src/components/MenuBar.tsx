'use client'

import { useState } from 'react'

export function MenuBar() {
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
        { label: '群組檢視', action: () => console.log('群組檢視') },
        { label: '位址排序', action: () => console.log('位址排序') },
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
        <div key={menu.name} className="relative">
          <button
            className="px-4 py-1 text-sm hover:bg-gray-300"
            onMouseEnter={() => setOpenMenu(menu.name)}
            onMouseLeave={() => setOpenMenu(null)}
          >
            {menu.name}
          </button>
          {openMenu === menu.name && (
            <div
              className="absolute top-full left-0 bg-white border border-gray-300 shadow-lg py-1 min-w-48 z-50"
              onMouseEnter={() => setOpenMenu(menu.name)}
              onMouseLeave={() => setOpenMenu(null)}
            >
              {menu.items.map((item, index) => (
                <button
                  key={index}
                  className="w-full text-left px-4 py-1 text-sm hover:bg-gray-100"
                  onClick={item.action}
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