---
name: antigravity-install-all
description: 一次安裝所有 AntiGravity 懶人包技能。說「全部安裝」「裝完所有 AntiGravity 懶人包」時載入。
---

# 一次安裝全部技能

依序載入並執行：

1. **01-notebooklm** — 連接 NotebookLM
2. **02-github** — 連接 GitHub
3. **03-firebase** — 連接 Firebase
4. **04-draw** — 生圖指引
5. **05-workflow** — 開工/收工/初始化
6. **06-obsidian** — 連接 Obsidian (MCPVault)
7. **07-nrf-mcp** — 連接 Nordic nRF MCP
8. **08-scope-drift-detector** — 任務錨點 + 六維飄移偵測（Autonomous Safety Policy v0.2）
9. **09-failure-classifier** — 失敗分類器，retry 前必呼叫
10. **10-loop-executor** — 執行引擎，強制每 3 次 iteration 自查並自動調用分類器
11. **11-harness-engineer** — 專案 Harness 初始化與審查器
12. **RTK (Rust Token Killer)** — 自動化安裝 `rtk` 並執行 `rtk init --agent antigravity`，實現終端機輸出 80% 的 Token 壓縮。

每完成一個報告進度，最終回報總表。
已安裝的工具自動跳過。
