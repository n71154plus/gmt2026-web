# GMT2026 Web 部署指南

## 🚀 快速部署到 Vercel

### 方法一：使用 Vercel CLI（推薦）

1. **安裝 Vercel CLI**：
   ```bash
   npm i -g vercel
   ```

2. **登入 Vercel**：
   ```bash
   vercel login
   ```

3. **部署項目**：
   ```bash
   cd gmt2026-web
   vercel
   ```

4. **按照提示操作**：
   - 選擇項目名稱
   - 確認部署區域（建議選擇亞洲區域如 Singapore）
   - 等待部署完成

### 方法二：使用 Vercel 網頁介面

1. **準備 GitHub 倉庫**：
   ```bash
   cd gmt2026-web
   git init
   git add .
   git commit -m "Initial commit: GMT2026 Web application"
   ```

2. **建立 GitHub 倉庫**：
   - 前往 [GitHub](https://github.com)
   - 點擊 "New repository"
   - 設定倉庫名稱（例如：`gmt2026-web`）
   - 不要初始化 README

3. **推送代碼**：
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/gmt2026-web.git
   git branch -M main
   git push -u origin main
   ```

4. **在 Vercel 中部署**：
   - 前往 [vercel.com](https://vercel.com)
   - 點擊 "New Project"
   - 連接到你的 GitHub 帳號
   - 選擇 `gmt2026-web` 倉庫
   - Vercel 會自動檢測 Next.js 項目
   - 點擊 "Deploy"

## ⚙️ 部署配置

### Vercel 環境變數

如果需要設定環境變數，可以在 Vercel 控制台中設定：

1. 進入項目設定
2. 點擊 "Environment Variables"
3. 添加以下變數（如果需要）：
   - `NODE_ENV`: `production`
   - `NEXT_PUBLIC_API_URL`: 你的 API 端點（如果有外部 API）

### 自訂域名

1. 在 Vercel 項目設定中
2. 點擊 "Domains"
3. 添加你的自訂域名
4. 按照指示設定 DNS

## 🔧 疑難排解

### 常見問題

1. **建置失敗**：
   ```bash
   # 本地測試建置
   npm run build

   # 檢查錯誤訊息
   npm run lint
   ```

2. **API 路由問題**：
   - 確保 API 檔案放在 `src/app/api/` 目錄下
   - 檢查路由名稱是否正確

3. **靜態資源問題**：
   - 圖片放在 `public/` 目錄
   - CSS 和 JS 會自動處理

### 檢查部署狀態

```bash
# 查看部署日誌
vercel logs

# 重新部署
vercel --prod
```

## 🌐 部署後的 URL

部署成功後，你會獲得一個類似以下的 URL：
- `https://gmt2026-web.vercel.app`
- `https://gmt2026-web-[random].vercel.app`

## 📊 效能優化

Vercel 會自動優化：
- 靜態資源快取
- 圖片優化
- API 路由快取
- CDN 分發

## 🔄 更新部署

每次推送代碼到主分支，Vercel 會自動重新部署：
```bash
git add .
git commit -m "Update: [描述變更]"
git push origin main
```

## 🛠️ 本地開發測試

在部署前，建議先在本機測試：

```bash
cd gmt2026-web
npm install
npm run dev
```

訪問 `http://localhost:3000` 測試功能。

## 📞 支援

如果遇到部署問題：
1. 檢查 Vercel 控制台的部署日誌
2. 查看 [Vercel 文檔](https://vercel.com/docs)
3. 檢查 [Next.js 部署指南](https://nextjs.org/docs/deployment)