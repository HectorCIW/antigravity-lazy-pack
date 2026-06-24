---
name: loop-executor
description: Use at the start of any multi-step task (3+ iterations expected) to initialize an iteration counter and enforce automatic drift checks, failure classification, and checkpoint triggers at defined intervals. This is the execution engine of Layer 2 that calls scope-drift-detector every 3 iterations and failure-classifier before every retry.
---
# Loop Executor

> For detailed design rationale and examples, read `references/rationale.md`.

## 1. Initialization (Call once at task start)

Record in `.agents/MISSION_ANCHOR.md`:

```markdown
## Loop State
- Iteration: 0
- Last drift check: —
- Consecutive failures: 0
- Status: RUNNING
```

## 2. Per-Iteration Protocol

Execute for every iteration:

1. Increment iteration counter.
2. Execute the planned action.
3. If FAILS:
   a. Call failure-classifier before retry.
   b. Increment consecutive failure counter.
   c. If == 2 -> escalate to Tier 2.
   d. If == 3 -> escalate to Tier 3, stop loop.
4. If SUCCEEDS:
   a. Reset consecutive failure counter to 0.
5. If iteration counter % 3 == 0 -> **use `invoke_subagent` to spawn a `research` or `self` subagent.** Send it the `MISSION_ANCHOR.md` and ask it to run the `scope-drift-detector` protocol. Wait for its verdict before continuing.
6. If immediate risk signal occurs -> spawn subagent to run `scope-drift-detector`.

### Immediate Risk Signals
- Plan changes
- >3 files modified
- Dependency/config modified
- Guessed external package
- Network/install/deploy/destructive action

## 3. Checkpoint Triggers
Call `bash .agents/scripts/checkpoint.sh "before_<action>"`:
- **Medium Risk**: Config change, dependency install, rename/delete, edit >3 files.
- **High Risk**: Destructive command, firmware flash, CI/CD change, `.env`, production deploy.

## 4. Loop Termination Conditions
- Success condition met -> Status: DONE. Call `docs-status-handoff`.
- Tier 3 triggered -> Status: ESCALATED. Stop.
- Stop condition met -> Status: STOPPED.
- User explicitly ends -> Status: INTERRUPTED.

Update Loop State in `.agents/MISSION_ANCHOR.md` on termination.
