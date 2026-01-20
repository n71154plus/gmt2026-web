'use client'

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react'

// 用戶類型定義
export interface User {
  id: string
  username: string
  email: string
  role: 'admin' | 'user' | 'viewer'
  permissions: Permission[]
  createdAt: Date
  lastLogin?: Date
}

export interface Permission {
  resource: string
  actions: ('read' | 'write' | 'delete' | 'execute')[]
}

export interface AuthState {
  user: User | null
  isAuthenticated: boolean
  isLoading: boolean
}

// 認證上下文類型
interface AuthContextType extends AuthState {
  login: (username: string, password: string) => Promise<{ success: boolean; error?: string }>
  logout: () => void
  hasPermission: (resource: string, action: 'read' | 'write' | 'delete' | 'execute') => boolean
  refreshUser: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

// 模擬用戶數據
const mockUsers: Record<string, { password: string; user: User }> = {
  'admin': {
    password: 'admin123',
    user: {
      id: '1',
      username: 'admin',
      email: 'admin@gmt.com',
      role: 'admin',
      permissions: [
        { resource: 'products', actions: ['read', 'write', 'delete'] },
        { resource: 'registers', actions: ['read', 'write'] },
        { resource: 'lua', actions: ['read', 'write', 'execute'] },
        { resource: 'hex', actions: ['read', 'write'] },
        { resource: 'settings', actions: ['read', 'write'] }
      ],
      createdAt: new Date('2024-01-01'),
      lastLogin: new Date()
    }
  },
  'user': {
    password: 'user123',
    user: {
      id: '2',
      username: 'user',
      email: 'user@gmt.com',
      role: 'user',
      permissions: [
        { resource: 'products', actions: ['read'] },
        { resource: 'registers', actions: ['read', 'write'] },
        { resource: 'lua', actions: ['read', 'execute'] },
        { resource: 'hex', actions: ['read'] }
      ],
      createdAt: new Date('2024-06-01'),
      lastLogin: new Date()
    }
  },
  'viewer': {
    password: 'viewer123',
    user: {
      id: '3',
      username: 'viewer',
      email: 'viewer@gmt.com',
      role: 'viewer',
      permissions: [
        { resource: 'products', actions: ['read'] },
        { resource: 'registers', actions: ['read'] },
        { resource: 'lua', actions: ['read'] },
        { resource: 'hex', actions: ['read'] }
      ],
      createdAt: new Date('2024-09-01')
    }
  }
}

// 認證提供者組件
export function AuthProvider({ children }: { children: ReactNode }) {
  const [state, setState] = useState<AuthState>({
    user: null,
    isAuthenticated: false,
    isLoading: true
  })

  // 從本地存儲恢復會話
  useEffect(() => {
    const savedUser = localStorage.getItem('gmt2026_user')
    if (savedUser) {
      try {
        const user = JSON.parse(savedUser)
        setState({
          user,
          isAuthenticated: true,
          isLoading: false
        })
      } catch {
        localStorage.removeItem('gmt2026_user')
        setState(prev => ({ ...prev, isLoading: false }))
      }
    } else {
      setState(prev => ({ ...prev, isLoading: false }))
    }
  }, [])

  // 登錄
  const login = async (username: string, password: string): Promise<{ success: boolean; error?: string }> => {
    setState(prev => ({ ...prev, isLoading: true }))

    // 模擬網絡延遲
    await new Promise(resolve => setTimeout(resolve, 500))

    const userRecord = mockUsers[username.toLowerCase()]
    if (!userRecord || userRecord.password !== password) {
      setState(prev => ({ ...prev, isLoading: false }))
      return { success: false, error: '用戶名或密碼錯誤' }
    }

    const user = { ...userRecord.user, lastLogin: new Date() }
    localStorage.setItem('gmt2026_user', JSON.stringify(user))

    setState({
      user,
      isAuthenticated: true,
      isLoading: false
    })

    return { success: true }
  }

  // 登出
  const logout = () => {
    localStorage.removeItem('gmt2026_user')
    setState({
      user: null,
      isAuthenticated: false,
      isLoading: false
    })
  }

  // 檢查權限
  const hasPermission = (resource: string, action: 'read' | 'write' | 'delete' | 'execute'): boolean => {
    if (!state.user) return false

    // 管理員擁有所有權限
    if (state.user.role === 'admin') return true

    const permission = state.user.permissions.find(p => p.resource === resource)
    return permission?.actions.includes(action) ?? false
  }

  // 刷新用戶信息
  const refreshUser = async () => {
    const savedUser = localStorage.getItem('gmt2026_user')
    if (savedUser) {
      try {
        const user = JSON.parse(savedUser)
        setState({
          user,
          isAuthenticated: true,
          isLoading: false
        })
      } catch {
        logout()
      }
    }
  }

  return (
    <AuthContext.Provider value={{
      ...state,
      login,
      logout,
      hasPermission,
      refreshUser
    }}>
      {children}
    </AuthContext.Provider>
  )
}

// 使用認證上下文
export function useAuth(): AuthContextType {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth 必須在 AuthProvider 內使用')
  }
  return context
}

// 權限檢查組件
export function PermissionCheck({
  resource,
  action,
  children,
  fallback = null
}: {
  resource: string
  action: 'read' | 'write' | 'delete' | 'execute'
  children: ReactNode
  fallback?: ReactNode
}) {
  const { hasPermission } = useAuth()

  if (!hasPermission(resource, action)) {
    return <>{fallback}</>
  }

  return <>{children}</>
}

// 角色檢查組件
export function RoleCheck({
  roles,
  children,
  fallback = null
}: {
  roles: ('admin' | 'user' | 'viewer')[]
  children: ReactNode
  fallback?: ReactNode
}) {
  const { user } = useAuth()

  if (!user || !roles.includes(user.role)) {
    return <>{fallback}</>
  }

  return <>{children}</>
}
