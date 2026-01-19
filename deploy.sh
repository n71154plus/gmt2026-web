#!/bin/bash

# GMT2026 Web 部署腳本

echo "🚀 開始部署 GMT2026 Web 到 Vercel..."

# 檢查是否有 Vercel CLI
if ! command -v vercel &> /dev/null; then
    echo "❌ 未安裝 Vercel CLI，請先執行：npm i -g vercel"
    echo "然後執行：vercel login"
    exit 1
fi

# 檢查是否已登入 Vercel
if ! vercel whoami &> /dev/null; then
    echo "❌ 未登入 Vercel，請先執行：vercel login"
    exit 1
fi

# 安裝依賴
echo "📦 安裝依賴..."
npm install

# 建置項目
echo "🔨 建置項目..."
npm run build

# 檢查建置是否成功
if [ $? -eq 0 ]; then
    echo "✅ 建置成功！"
    echo ""
    echo "📋 部署選項："
    echo "1. 使用此腳本自動部署（需要先設定 Git 倉庫）"
    echo "2. 手動推送到 GitHub，然後在 Vercel 網頁介面部署"
    echo ""

    read -p "是否現在部署到 Vercel？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🌐 開始部署到 Vercel..."
        vercel --prod

        if [ $? -eq 0 ]; then
            echo "✅ 部署成功！"
            echo "🌐 請檢查 Vercel 提供的 URL"
        else
            echo "❌ 部署失敗！請檢查錯誤訊息。"
            exit 1
        fi
    else
        echo "📋 手動部署步驟："
        echo "1. 建立 GitHub 倉庫：git init && git add . && git commit -m 'Initial commit'"
        echo "2. 推送到 GitHub：git remote add origin <your-repo-url> && git push -u origin main"
        echo "3. 在 https://vercel.com 連接到倉庫並部署"
    fi
else
    echo "❌ 建置失敗！請檢查錯誤訊息。"
    echo ""
    echo "🔧 疑難排解："
    echo "1. 執行 npm run lint 檢查語法錯誤"
    echo "2. 執行 npm run type-check 檢查 TypeScript 錯誤"
    echo "3. 確保所有依賴都已安裝"
    exit 1
fi