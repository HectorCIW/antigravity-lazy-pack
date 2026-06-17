---
name: antigravity-nrf-mcp
description: 在 AntiGravity 連接 Nordic nRF Connect SDK MCP。說「連接 Nordic」「設定 nRF」時載入。
---

# 連接 Nordic nRF Connect SDK MCP（AntiGravity 版）

## 步驟

### 1. 複製並編譯 nrf-mcp 伺服器
```bash
git clone https://github.com/pshanesmith/nrf-mcp.git ~/Documents/nrf-mcp
cd ~/Documents/nrf-mcp
npm install
npm run build
```

### 2. 註冊 MCP
在您的 MCP 設定檔（例如 `~/.gemini/config/mcp_config.json`）的 `mcpServers` 物件中加入以下內容：
```json
"nrf-mcp": {
  "command": "/bin/bash",
  "args": [
    "/Users/wujunyi/Documents/nrf-mcp/run.sh"
  ]
}
```

### 3. 驗證
重新啟動 AntiGravity，然後嘗試使用以下工具：
- `nrf_search`: 搜尋 SDK 中的程式碼或範例。

⚠️ 安全提醒：在使用 GitHub Code Search 時，若遇上限流，建議在系統環境變數中設定 `GITHUB_TOKEN`。
