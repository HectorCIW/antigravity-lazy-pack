## Mission Anchor

**User intent:**
維護並演進 antigravity-lazy-pack 作為 HectorCIW 的通用 Antigravity 懶人包與 harness 基礎設施。

**Allowed scope:**
- `/Users/wujunyi/.gemini/antigravity/scratch/antigravity-lazy-pack/` 內所有檔案
- `~/.gemini/config/skills/`（全域 skill 更新）
- `~/.gemini/config/AGENTS.md`（全域規則更新）
- `HectorCIW/antigravity-lazy-pack` GitHub repo

**Out of scope:**
- 不修改 `mathruffian-dot/` 或 `multica-ai/` 等外部 repo
- 不動其他 GitHub repo（Agent_flexNIRS_Hector_v1、taiwan-street-eats、NIRS-DCS）除非明確指示
- 不 push 任何 repo 除非明確確認

**Success condition:**
專案 harness 完整（PROJECT_STATUS.md 填妥、AGENTS.md 存在、.agents/ 結構齊全），skills 均可正常觸發。

**Stop condition:**
涉及外部 repo 寫入、生產部署、或不確定的破壞性操作 → Tier 2 確認。

---
## Quick Drift Check（每 3 次 iteration 自查）
- [ ] 還在 allowed scope 內？
- [ ] 沒有猜測未驗證的套件或 API 名稱？
- [ ] 同一操作失敗次數 < 2？
- [ ] 沒有修改 > 3 個檔案（未確認的情況下）？
