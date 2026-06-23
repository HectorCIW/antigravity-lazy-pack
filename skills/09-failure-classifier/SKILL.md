---
name: failure-classifier
description: Use immediately after any task failure — test failure, command failure, tool error, permission error, missing file, or API error — before retrying. Classifies the failure type so the correct recovery action is taken. Prevents the agent from repeating the same wrong fix.
---
# Failure Classifier

> For detailed design rationale and examples, read `references/rationale.md`.

## 1. Classification Table (Match exact error)

| Failure type | Key signal | Recovery action | Escalation |
|---|---|---|---|
| **Syntax failure** | Parse error, SyntaxError, linting error | Implementer fixes locally | None unless 3 retries fail |
| **Test failure** | Test assertion failed, expected vs actual mismatch | Implementer debugs logic | Tier 2 if test design is ambiguous |
| **Dependency failure** | `ModuleNotFoundError`, `Cannot find module`, `command not found` | Install missing package | Tier 2 if package name is unverified |
| **Permission failure** | `Permission denied`, `EACCES`, `403`, `sudo required` | Do not retry. Escalate immediately | Tier 2 or Tier 3 depending on scope |
| **Missing file** | `FileNotFoundError`, `ENOENT`, `No such file or directory` | Check if file was supposed to exist. Create or ask. | Tier 2 if file is outside project scope |
| **Wrong assumption** | Command runs but output is unexpected. Package exists but has wrong API. | Stop. Re-read Mission Anchor. Replan. | Tier 2 if user assumption was baked in |
| **External service failure** | API timeout, 503, rate limit, DNS failure | Retry once with backoff. Then escalate. | Tier 2 after 1 retry |
| **User clarification needed** | Ambiguous intent, multiple valid interpretations, conflicting instructions | Do not guess. Ask. | Tier 2 always |
| **Irreversible action attempted** | rm -rf, force push, production deploy, firmware flash | Stop immediately. Do not execute. | Tier 3 always |
| **Tool/framework error** | `Permission denied for tool`, MCP `internal error`, tool timeout, `run_command` timeout | Do not retry with same tool. Try alternative tool or method. Verify tool config. | Tier 2 if no alternative exists |

## 2. Retry Limit Rules
- Same failure type, same root cause: **max 2 retries**.
- After 2 retries with no different approach: escalate to Tier 2.
- After 3 retries total (any approach): escalate to Tier 3.
- **Never retry a permission failure or an irreversible action.** Escalate immediately.

## 3. Log the Failure (Append to `.agents/COMMAND_LOG.md`)
```markdown
### [timestamp] Failure classified
Command: <exact command>
Error: <exact error message>
Type: <failure type>
Recovery action: <what will be done>
Escalation: <None | Tier 1 | Tier 2 | Tier 3>
```

## 4. Output Format
```markdown
## Failure Classification
Command: <exact command>
Error: <exact error message>
Type: <failure type>
Deterministic: Yes / No / Unknown
Retry limit reached: Yes / No (attempt <N> of 2)
Recovery action: <what will happen next>
Escalation: <None | Tier 2 — reason | Tier 3 — reason>
```
