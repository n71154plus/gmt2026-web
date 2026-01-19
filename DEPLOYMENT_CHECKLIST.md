# 🚀 GMT2026 Web 部署檢查清單

## 前置準備

- [ ] 安裝 Node.js (建議 v18 或更高版本)
- [ ] 安裝 Git
- [ ] 註冊 GitHub 帳號
- [ ] 註冊 Vercel 帳號

## 本地測試

- [ ] 執行 `npm install` 安裝依賴
- [ ] 執行 `npm run build` 檢查建置
- [ ] 執行 `npm run lint` 檢查程式碼品質
- [ ] 執行 `npm run dev` 測試本地運行
- [ ] 訪問 http://localhost:3000 確認功能正常

## 版本控制

- [ ] 建立 GitHub 倉庫
- [ ] 推送程式碼到 GitHub
- [ ] 確認所有必要檔案已上傳（檢查 .gitignore）

## Vercel 部署

- [ ] 在 Vercel 中連接到 GitHub 倉庫
- [ ] 設定建置命令（自動檢測）
- [ ] 設定環境變數（如果需要）
- [ ] 啟動部署
- [ ] 等待部署完成
- [ ] 測試部署後的 URL

## 部署後檢查

- [ ] 確認網站可以正常訪問
- [ ] 測試主要功能（產品選擇、介面操作等）
- [ ] 檢查 API 路由是否正常工作
- [ ] 驗證響應式設計在不同設備上正常
- [ ] 檢查控制台是否有錯誤訊息

## 效能優化

- [ ] 檢查 Lighthouse 評分
- [ ] 優化圖片和靜態資源
- [ ] 設定適當的快取策略
- [ ] 監控載入時間

## 安全檢查

- [ ] 移除所有測試用的敏感資訊
- [ ] 確認環境變數安全設定
- [ ] 檢查是否有安全漏洞
- [ ] 設定適當的 CORS 政策

## 文檔更新

- [ ] 更新 README.md 說明
- [ ] 記錄已知問題和限制
- [ ] 提供使用者操作指南
- [ ] 記錄維護和更新流程

---

## 快速部署命令

```bash
# 1. 本地測試
npm install && npm run build && npm run lint

# 2. 版本控制
git init
git add .
git commit -m "Deploy GMT2026 Web"
git remote add origin https://github.com/YOUR_USERNAME/gmt2026-web.git
git push -u origin main

# 3. Vercel 部署（需要先安裝 CLI）
npm i -g vercel
vercel login
vercel --prod
```

## 常見問題排除

### 建置失敗
- 檢查 Node.js 版本
- 確認所有依賴都已安裝
- 查看建置日誌中的具體錯誤

### 部署失敗
- 檢查 Vercel 控制台的部署日誌
- 確認環境變數設定正確
- 檢查網路連線

### 功能異常
- 檢查瀏覽器控制台錯誤
- 確認 API 路由正確設定
- 測試網路請求是否正常

---

✅ **完成所有檢查項目後，你的 GMT2026 Web 應用程式就可以成功部署到 Vercel 了！**