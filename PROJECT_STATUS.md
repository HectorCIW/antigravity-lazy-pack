# Project Status

Last updated: 2026-06-23

## Purpose
HectorCIW 的 Antigravity 懶人包集合與自主 agent harness 基礎設施。
包含 AntiGravity 全域工作流 skills（NotebookLM、GitHub、Firebase、Obsidian、生圖、nRF MCP）以及 v0.2 Autonomous Safety Policy harness（scope-drift-detector、failure-classifier）。

## Current state
- Status: Active — v0.2 Autonomous Safety Policy 已實裝
- Active milestone: 維護與演進 harness 架構
- Repo: https://github.com/HectorCIW/antigravity-lazy-pack

## Skills inventory

| # | Skill | 功能 |
|---|---|---|
| 00 | antigravity-install-all | 一次安裝全部 |
| 01 | antigravity-notebooklm | 連接 NotebookLM MCP |
| 02 | antigravity-github | 連接 GitHub CLI |
| 03 | antigravity-firebase | 連接 Firebase MCP |
| 04 | antigravity-draw | 生圖指引 |
| 05 | antigravity-workflow | 開工/收工/初始化 |
| 06 | antigravity-obsidian | 連接 Obsidian MCP |
| 07 | antigravity-nrf-mcp | 連接 Nordic nRF MCP |
| 08 | scope-drift-detector | Mission Anchor + 六維飄移偵測 |
| 09 | failure-classifier | 9 種失敗分類，retry 前必呼叫 |

## Global config files touched
- `~/.gemini/config/skills/scope-drift-detector/SKILL.md` — 新建
- `~/.gemini/config/skills/failure-classifier/SKILL.md` — 新建
- `~/.gemini/config/skills/harness-engineer/SKILL.md` — v0.2 更新
- `~/.gemini/config/AGENTS.md` — 新增 Autonomous Safety Policy（精簡版）

## How to run
```bash
# 無獨立 run command，這是 skill 集合 repo
# 安裝方式：複製 skills/ 目錄下的對應資料夾到 ~/.gemini/config/skills/
```

## Recent changes
- 2026-06-23 — v0.2 Autonomous Safety Policy 實裝（skills 08、09）
- 2026-06-23 — install-all 更新，加入 08、09
- 2026-06-23 — AGENTS.md 壓縮（9.7KB → 7.0KB，節省 ~680 tok/對話）
- 2026-06-23 — 加入人性化溝通規則、論文級語氣規則、Karpathy 準則
- 2026-06-23 — 初始 bootstrap（skills 00–07）

## Known issues
- Layer 2–3（Rating Agent、Loop Executor）尚未實裝為獨立 skill，目前由 Orchestrator 兼任

## Next steps
1. 實裝 `antigravity-workflow` 開工流程以觸發 Mission Anchor（已完成本次開工）
2. 視需求新增 domain-specific skills
3. 考慮加入 `checkpoint.sh` bootstrap script 到 00-install-all 安裝流程
