const fs = require('fs');
const content = fs.readFileSync('public/scripts/lua/L102.19.lua', 'utf-8');

// 測試解析
const productMatch = content.match(/New\.Product\s*\{([^}]+)\}/s);
console.log('Product 匹配數量:', productMatch ? 1 : 0);

if (productMatch) {
  const productContent = productMatch[1];
  console.log('Product 內容長度:', productContent.length);
  
  const rtMatch = productContent.match(/RegisterTable\s*=\s*\{/);
  console.log('RegisterTable 匹配:', rtMatch ? '找到' : '未找到');
  
  if (rtMatch) {
    const rtStart = productContent.indexOf('{', rtMatch.index + 15);
    console.log('RegisterTable { 位置:', rtStart);
  }
}
