---
name: loop-executor
description: Use at the start of any multi-step task (3+ iterations expected) to initialize an iteration counter and enforce automatic drift checks, failure classification, and checkpoint triggers at defined intervals. This is the execution engine of Layer 2 that calls scope-drift-detector every 3 iterations and failure-classifier before every retry.
---
# Loop Executor

## Purpose

Transforms a multi-step plan into a governed execution loop. Without this skill, drift checks and failure classification depend on the agent remembering to trigger them — which is unreliable. This skill makes those triggers mechanical, not discretionary.

---

## Initialization (call once at task start, after Mission Anchor is written)

Set iteration counter to 0. Record in `.agents/MISSION_ANCHOR.md`:

```markdown
## Loop State
- Iteration: 0
- Last drift check: —
- Consecutive failures: 0
- Status: RUNNING
```

---

## Per-iteration protocol

Execute this sequence for every iteration of the task loop:

```
1. Increment iteration counter.
2. Execute the planned action for this iteration.
3. If the action FAILS:
   a. Call failure-classifier before any retry.
   b. Increment consecutive failure counter.
   c. If consecutive failures == 2 → escalate to Tier 2.
   d. If consecutive failures == 3 → escalate to Tier 3, stop loop.
4. If the action SUCCEEDS:
   a. Reset consecutive failure counter to 0.
5. If iteration counter is a multiple of 3 → call scope-drift-detector.
6. If any immediate risk signal occurs → call scope-drift-detector regardless of counter.
```

### Immediate risk signals (trigger drift check out of cycle)

- Implementation plan changes
- More than 3 files modified in one iteration
- Dependency or config file modified
- External package name was guessed rather than verified
- Network, install, deploy, or destructive action requested

---

## Checkpoint triggers (within the loop)

Call `bash .agents/scripts/checkpoint.sh "before_<action>"` before any action classified as:

| Risk level | When to checkpoint |
|---|---|
| Medium | Config change, dependency install, rename/delete, editing >3 files |
| High | Destructive command, firmware flash, CI/CD change, `.env` edit, production deploy |

Low-risk iterations: no checkpoint needed.

---

## Loop termination conditions

The loop ends when:

| Condition | Action |
|---|---|
| Success condition from Mission Anchor is met | Mark `Status: DONE`. Call `docs-status-handoff`. |
| Tier 3 escalation triggered | Mark `Status: ESCALATED`. Stop. Hand over context. |
| Stop condition from Mission Anchor is met | Mark `Status: STOPPED`. Report to user. |
| User explicitly ends the task | Mark `Status: INTERRUPTED`. |

Update Loop State in `.agents/MISSION_ANCHOR.md` on termination.

---

## Loop State format (update after each iteration)

```markdown
## Loop State
- Iteration: <N>
- Last drift check: Iteration <M> — <CONTINUE/REPLAN/ESCALATE>
- Consecutive failures: <N>
- Status: RUNNING / DONE / ESCALATED / STOPPED / INTERRUPTED
```

---

## Integration with other components

- **Project Orchestrator (Layer 1)**: Writes the Mission Anchor and hands off to Loop Executor.
- **scope-drift-detector (Layer 4)**: Called every 3 iterations and on risk signals.
- **failure-classifier (Layer 5)**: Called before every retry.
- **harness-engineer**: Bootstraps the checkpoint script before the loop starts.
- **docs-status-handoff (Layer 6)**: Called on successful loop termination.

---

## Minimal overhead note

This skill does not require reading the full skill file on every iteration. The agent only needs to:
1. Maintain the Loop State block in `MISSION_ANCHOR.md` (already open).
2. Know the two trigger numbers: **every 3 iterations** and **after 2 consecutive failures**.

Full skill reload is only needed if the loop protocol itself needs to be consulted.
