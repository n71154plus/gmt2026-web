# GMT2026 Web - I2C設備配置工具網頁版本

這是GMT2026 I2C設備配置工具的網頁版本，可以在Vercel上運行。

## 功能特點

- 🎯 **產品選擇**：支援多種I2C設備配置
- 🔧 **I2C操作**：讀寫暫存器數據
- 📊 **圖表顯示**：可視化設備參數
- 📁 **HEX文件處理**：匯入匯出配置
- ⚡ **即時驗證**：規則檢查和狀態監控

## 技術架構

- **前端**：Next.js 14 + TypeScript + Tailwind CSS
- **後端**：Next.js API Routes (Node.js)
- **部署**：Vercel
- **狀態管理**：React Hooks

## 本地開發

1. 安裝依賴：
```bash
npm install
```

2. 啟動開發服務器：
```bash
npm run dev
```

3. 在瀏覽器中開啟 [http://localhost:3000](http://localhost:3000)

## 部署到 Vercel

### 快速部署

1. **使用自動化腳本**：
```bash
chmod +x deploy.sh
./deploy.sh
```

2. **手動部署**：
   - 推送到 GitHub 倉庫
   - 在 [vercel.com](https://vercel.com) 連接到倉庫
   - 自動部署

詳細部署步驟請參考 [DEPLOYMENT.md](./DEPLOYMENT.md)

## Vercel部署

1. 將代碼推送到GitHub倉庫

2. 在Vercel中導入項目：
   - 連接到你的GitHub倉庫
   - 自動檢測Next.js項目
   - 點擊"Deploy"

3. 部署完成後，你會獲得一個公開URL

## 項目結構

```
src/
├── app/                    # Next.js App Router
│   ├── api/               # API路由
│   │   ├── i2c/          # I2C操作API
│   │   ├── lua/          # Lua腳本執行API
│   │   └── products/     # 產品數據API
│   ├── layout.tsx        # 根佈局
│   ├── page.tsx          # 首頁
│   └── globals.css       # 全域樣式
├── components/            # React組件
│   ├── MainWindow.tsx    # 主窗口
│   ├── TitleBar.tsx      # 標題列
│   ├── MenuBar.tsx       # 選單列
│   ├── StatusBar.tsx     # 狀態列
│   ├── LeftPanel.tsx     # 左側面板
│   └── MainContent.tsx   # 主要內容
├── lib/                  # 工具函數
└── types/                # TypeScript類型定義
```

## 主要組件說明

### MainWindow
整個應用程式的主要容器，管理全域狀態和組件間的通訊。

### LeftPanel
包含產品選擇、I2C Adapter配置、設備位址選擇和Lua函數按鈕。

### MainContent
顯示暫存器數據的網格視圖和暫存器列表。

### API路由
- `/api/products` - 獲取可用產品列表
- `/api/lua` - 執行Lua腳本函數
- `/api/i2c` - 模擬I2C操作

## 限制說明

由於瀏覽器安全限制，無法直接訪問真實的I2C硬體設備。本版本提供模擬功能用於演示和測試。在實際生產環境中，需要配合服務器端I2C硬件接口。

## 開發計劃

- [ ] 實現完整的Lua腳本解析器
- [ ] 添加圖表顯示功能
- [ ] 實現HEX文件處理
- [ ] 添加用戶認證和權限管理
- [ ] 優化響應式設計
- [ ] 添加測試覆蓋

## 貢獻

歡迎提交Issue和Pull Request來改進這個項目。