'use client';

import { useState, useEffect, useCallback, useRef, forwardRef } from 'react';
import { DataBits } from '@/lib/dataBits';

interface ByteGridProps {
  dataBits: DataBits;
  visibleIndices?: number[];
  headerFormat?: string;
  className?: string;
  onByteChanged?: (index: number, value: number) => void;
}

/**
 * ByteGrid 組件 - 顯示和編輯位元組數據的網格
 */
const ByteGrid = forwardRef<HTMLDivElement, ByteGridProps>(({
  dataBits,
  visibleIndices,
  headerFormat = "0x{0:X2}",
  className = '',
  onByteChanged
}, ref) => {

  const [byteValues, setByteValues] = useState<number[]>([]);
  const [editingIndex, setEditingIndex] = useState<number | null>(null);
  const [editValue, setEditValue] = useState('');
  // 使用 ref 來追蹤初始化狀態，避免循環更新
  const isInitializingRef = useRef(false);
  // 暫存待更新的值，等初始化完成後再一次性更新
  const pendingUpdatesRef = useRef<Map<number, number>>(new Map());

  // 確定要顯示的索引
  const indices = visibleIndices || Array.from({ length: dataBits.byteCount }, (_, i) => i);

  // 處理待更新的位元組
  const processPendingUpdates = useCallback(() => {
    const pending = pendingUpdatesRef.current;
    if (pending.size > 0) {
      setByteValues(prev => {
        const updated = [...prev];
        pending.forEach((value, index) => {
          if (index < updated.length) {
            updated[index] = value;
          }
        });
        pending.clear();
        return updated;
      });
    }
  }, []);

  // 組件掛載和dataBits變化時更新
  useEffect(() => {
    // 設置初始化標誌
    isInitializingRef.current = true;

    // 立即更新初始值（從 dataBits 讀取）
    const initialValues = indices.map(index => {
      try {
        return dataBits.getByte(index);
      } catch {
        return 0;
      }
    });
    setByteValues(initialValues);

    // 延遲一段時間後清除初始化標誌
    // 在這段時間內，所有來自 dataBits 的事件都會被忽略
    const timer = setTimeout(() => {
      isInitializingRef.current = false;
      // 處理任何在初始化期間累積的更新
      if (pendingUpdatesRef.current.size > 0) {
        processPendingUpdates();
      }
    }, 300);

    // 訂閱位元組變更事件
    const unsubscribe = dataBits.onByteChanged((index) => {
      if (!indices.includes(index)) return;

      const newValue = dataBits.getByte(index);

      if (isInitializingRef.current) {
        // 在初始化期間，只暫存值，不做任何其他操作
        pendingUpdatesRef.current.set(index, newValue);
        return;
      }

      // 使用函數式更新，避免依賴 byteValues
      setByteValues(prev => {
        const byteIndex = indices.indexOf(index);
        if (byteIndex < 0 || byteIndex >= prev.length) return prev;

        if (prev[byteIndex] !== newValue) {
          const updated = [...prev];
          updated[byteIndex] = newValue;

          // 只有在值確實改變時才通知外部
          // 這裡需要使用 setTimeout 來避免在更新回調中觸發外部更新
          setTimeout(() => {
            onByteChanged?.(index, newValue);
          }, 0);

          return updated;
        }

        return prev;
      });
    });

    return () => {
      clearTimeout(timer);
      unsubscribe();
    };
  }, [dataBits, indices, onByteChanged, processPendingUpdates]);

  // 處理編輯開始
  const handleEditStart = (index: number) => {
    const actualIndex = indices[index];
    const currentValue = byteValues[index];
    setEditingIndex(index);
    setEditValue(currentValue.toString(16).toUpperCase().padStart(2, '0'));
  };

  // 處理編輯確認
  const handleEditConfirm = () => {
    if (editingIndex === null) return;

    const actualIndex = indices[editingIndex];
    try {
      // 支持16進制和10進制輸入
      const value = editValue.startsWith('0x') || editValue.startsWith('0X')
        ? parseInt(editValue, 16)
        : parseInt(editValue, 10);

      if (!isNaN(value) && value >= 0 && value <= 255) {
        dataBits.setByte(actualIndex, value);
        // DataBits 的 setByte 會自動觸發事件和狀態更新
      }
    } catch (error) {
      console.error('Invalid byte value:', editValue);
    }

    setEditingIndex(null);
    setEditValue('');
  };

  // 處理編輯取消
  const handleEditCancel = () => {
    setEditingIndex(null);
    setEditValue('');
  };

  // 處理鍵盤事件
  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleEditConfirm();
    } else if (e.key === 'Escape') {
      handleEditCancel();
    }
  };

  // 處理輸入變化
  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setEditValue(e.target.value);
  };

  // 格式化標題
  const formatHeader = (index: number): string => {
    // 將 {0:X2} 格式替換為十六進制格式
    const hexValue = index.toString(16).toUpperCase().padStart(2, '0');
    return headerFormat.replace('{0:X2}', hexValue);
  };

  return (
    <div ref={ref} className={`byte-grid ${className}`}>
      {/* 標題行 */}
      <div className="flex border-b border-gray-300 bg-gray-50">
        <div className="flex-1 overflow-x-auto">
          <div className="flex min-w-max">
            {indices.map((index) => (
              <div
                key={`header-${index}`}
                className="w-11 text-center text-xs font-mono text-gray-600 border-r border-gray-300 px-1 py-1"
                style={{ fontFamily: 'Consolas, "Cascadia Mono", "Courier New", monospace' }}
                title={`Address 0x${index.toString(16).toUpperCase().padStart(2, '0')}`}
              >
                {formatHeader(index)}
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* 數據行 */}
      <div className="flex">
        <div className="flex-1 overflow-x-auto">
          <div className="flex min-w-max">
            {byteValues.map((value, displayIndex) => {
              const actualIndex = indices[displayIndex];
              const isEditing = editingIndex === displayIndex;

              return (
                <div
                  key={`data-${actualIndex}`}
                  className="w-11 border-r border-gray-300"
                >
                  {isEditing ? (
                    <input
                      type="text"
                      value={editValue}
                      onChange={handleInputChange}
                      onKeyDown={handleKeyDown}
                      onBlur={handleEditConfirm}
                      className="w-full h-full text-center text-xs bg-white border-none focus:outline-none focus:ring-1 focus:ring-blue-500"
                      style={{
                        fontFamily: 'Consolas, "Cascadia Mono", "Courier New", monospace',
                        padding: 0,
                        height: '24px',
                        textTransform: 'uppercase'
                      }}
                      maxLength={2}
                      autoFocus
                      onFocus={(e) => e.target.select()}
                    />
                  ) : (
                    <div
                      className="w-full h-full text-center text-xs text-gray-800 hover:bg-gray-100 cursor-pointer px-1 py-1 flex items-center justify-center"
                      style={{
                        fontFamily: 'Consolas, "Cascadia Mono", "Courier New", monospace',
                        height: '24px'
                      }}
                      onClick={() => handleEditStart(displayIndex)}
                      title={`Click to edit byte at address 0x${actualIndex.toString(16).toUpperCase().padStart(2, '0')}`}
                    >
                      {value.toString(16).toUpperCase().padStart(2, '0')}
                    </div>
                  )}
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </div>
  );
});

ByteGrid.displayName = 'ByteGrid';

export default ByteGrid;