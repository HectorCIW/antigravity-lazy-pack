## Mission Anchor

**User intent:**
用新架構（scope-drift-detector、failure-classifier、harness-engineer v0.2、Autonomous Safety Policy）審查這套新架構本身，找出設計缺陷、內部矛盾、執行落差、遺漏邊界。

**Allowed scope:**
- 讀取所有相關 skill 文件（scope-drift-detector、failure-classifier、harness-engineer、AGENTS.md）
- 讀取架構文件（autonomous_agent_architecture.md）
- 只輸出審查報告，不修改任何 skill 文件

**Out of scope:**
- 不修改任何 skill 或 config 文件（除非審查後明確被要求）
- 不 push 任何東西

**Success condition:**
產出一份結構化審查報告，涵蓋：設計缺陷、內部矛盾、執行落差、遺漏邊界、建議。

**Stop condition:**
如果發現需要修改超過 3 個 skill 文件 → Tier 2，先列出再確認。

---
## Quick Drift Check
- [ ] 任務是「審查」，不是「修改」
- [ ] 沒有猜測任何未驗證的資訊
- [ ] 同一操作失敗次數 < 2
- [ ] 沒有未經確認修改任何文件
