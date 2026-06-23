---
name: scope-drift-detector
description: Use at task start to define a Mission Anchor, and during execution to detect whether the agent has drifted from the original intent. Trigger every 3 iterations, or immediately when the plan changes, more than 3 files are modified, config/dependency files are touched, tests fail twice, commands fail twice, or a network/install/deploy/destructive action is requested.
---
# Scope Drift Detector

> For detailed design rationale and examples, read `references/rationale.md`.

## 1. Write the Mission Anchor (Task Start)

Create/overwrite `.agents/MISSION_ANCHOR.md`:

```markdown
## Mission Anchor
**User intent:** <One sentence describing the exact requested outcome.>
**Allowed scope:** <Files, folders, commands, domains, packages explicitly in scope.>
**Out of scope:** <Actions, files, or domains the agent must not touch unless explicitly approved.>
**Success condition:** <How we know the task is complete.>
**Stop condition:** <When the agent must pause or escalate.>
```

## 2. Compute Drift Score (Every 3 iterations or Risk Signal)

| Dimension | PASS | WARN | FAIL |
|---|---|---|---|
| **Mission similarity** | Matches user intent | Adjacent but not requested | Solving different problem |
| **Constraint violation** | Within allowed scope | Touches allowed-but-sensitive | Explicitly out of scope |
| **File scope change** | <=2 files, all in scope | 3 files, or 1 unexpected | >3 files, or outside scope |
| **Tool/action mismatch** | Expected for this task | Workaround | No clear relation to task |
| **Plan deviation** | Executing written plan | Minor deviation with reason | Plan changed without re-anchoring |
| **Repeated failure** | 0-1 failures | 2 failures on same operation | 3+ failures, or same error type |

**Scoring Rule:**
- 0-1 WARN, 0 FAIL -> Continue.
- 2+ WARN -> Log warning, continue with caution.
- Any FAIL -> Stop. Re-read Anchor. Re-plan or escalate.

## 3. Immediate Risk Signals (Trigger check immediately)
- Implementation plan changes
- >3 files modified in one iteration
- Dependency or config file modified
- Guessed external package name
- Tests or commands fail twice in a row
- Network, install, deploy, or destructive action requested
- Agent solving unanchored problem

## 4. Output Format

```markdown
## Scope Drift Check
Iteration: <N>
Trigger: <check type>

| Dimension | Status | Note |
|---|---|---|
| ... | PASS/WARN/FAIL | ... |

**Overall: CONTINUE / REPLAN / ESCALATE**
Reason: <one sentence>
```

If WARN or FAIL, append to `.agents/MISSION_ANCHOR.md`:
```markdown
## WARN Log
- [<timestamp>] <Dimension>: <note> — Overall: <CONTINUE/REPLAN/ESCALATE>
```
