---
name: scope-drift-detector
description: Use at task start to define a Mission Anchor, and during execution to detect whether the agent has drifted from the original intent. Trigger every 3 iterations, or immediately when the plan changes, more than 3 files are modified, config/dependency files are touched, tests fail twice, commands fail twice, or a network/install/deploy/destructive action is requested.
---
# Scope Drift Detector

## Purpose

Distinguish between *doing too much of the right thing* (overbaking, handled elsewhere) and *doing the wrong thing entirely* (scope drift). Cosine similarity alone cannot catch operational drift — for example, searching for a plausible-sounding package that was never verified. This skill implements a structured Mission Anchor check and a multi-dimensional drift score.

---

## Step 1 — Write the Mission Anchor at task start

Before any implementation begins, write this block to `.agents/MISSION_ANCHOR.md` (create the file if it does not exist, overwrite if restarting a task):

```markdown
## Mission Anchor

**User intent:**
<One sentence describing the exact requested outcome.>

**Allowed scope:**
<Files, folders, commands, domains, packages explicitly in scope.>

**Out of scope:**
<Actions, files, or domains the agent must not touch unless explicitly approved.>

**Success condition:**
<How we know the task is complete — a passing test, a confirmed output, a user sign-off.>

**Stop condition:**
<When the agent must pause or escalate — 3 failures, unexpected permission errors, external API not verified, etc.>
```

Example:

```markdown
## Mission Anchor

**User intent:**
Install and configure the official Nordic Semiconductor MCP server so that nRF Connect tools are available inside Antigravity.

**Allowed scope:**
.gemini/config/, mcp_config.json, npm global packages from verified @nordicsemiconductor scope.

**Out of scope:**
Guessing package names. Modifying firmware source files. Touching unrelated MCP configs.

**Success condition:**
`nrf-mcp` appears in the active MCP server list and at least one nrf_list call succeeds.

**Stop condition:**
Package name cannot be verified from official docs → escalate to Tier 2.
```

---

## Step 2 — Compute the drift score (re-check every 3 iterations, or immediately on a risk signal)

Evaluate each dimension and assign a flag (PASS / WARN / FAIL):

| Dimension | PASS | WARN | FAIL |
|---|---|---|---|
| **Mission similarity** | Current action matches user intent | Action is adjacent but not directly requested | Action is solving a different problem |
| **Constraint violation** | All actions within allowed scope | One action touches allowed-but-sensitive scope | Action is explicitly out of scope |
| **File scope change** | ≤2 files touched, all in scope | 3 files, or one unexpected file | >3 files, or file outside allowed scope |
| **Tool/action mismatch** | Tool used is expected for this task | Tool used is a workaround | Tool used has no clear relation to the task |
| **Plan deviation** | Executing the written plan | Minor deviation with good reason | Plan changed significantly without re-anchoring |
| **Repeated failure signal** | 0–1 failures | 2 failures on same operation | 3+ failures, or same error type repeated |

### Scoring rule

- 0–1 WARN, 0 FAIL → Continue.
- 2+ WARN → Log warning, continue with caution, re-check next iteration.
- Any FAIL → Stop. Re-read Mission Anchor. Either re-plan or escalate.

---

## Immediate re-check triggers (do not wait for 3 iterations)

Re-check scope drift immediately when:

- The implementation plan changes
- More than 3 files are modified in one iteration
- A dependency or config file is modified
- An external package name was guessed (not verified from official documentation)
- Tests fail twice in a row
- The same command fails twice in a row
- A network, install, deploy, or destructive action is requested
- The agent finds itself solving a problem not described in the Mission Anchor

---

## Step 3 — Drift recovery actions

| Drift level | Action |
|---|---|
| WARN | Log the anomaly. Continue. Flag for next check. |
| FAIL (recoverable) | Stop. Re-read Mission Anchor. Restate the current plan. Adjust and continue. |
| FAIL (ambiguous intent) | Stop. Summarize what the agent has tried and why it is stuck. Ask the user for clarification. |
| FAIL (out-of-scope action completed) | Trigger Checkpoint & Rollback. Escalate to Tier 2 or Tier 3. |

---

## Integration with other components

- **Project Orchestrator**: Writes the Mission Anchor at task start.
- **Loop Executor**: Calls drift re-check every 3 iterations.
- **Failure Classifier**: Feeds the "repeated failure signal" dimension.
- **Human Escalation Protocol**: Receives drift FAILs that require user input.
- **Checkpoint & Rollback**: Triggered when an out-of-scope action was already taken.

---

## Output format

When drift is detected, produce:

```markdown
## Scope Drift Check

Iteration: <N>
Trigger: <3-iteration check | risk signal: <what triggered it>>

| Dimension | Status | Note |
|---|---|---|
| Mission similarity | PASS/WARN/FAIL | ... |
| Constraint violation | PASS/WARN/FAIL | ... |
| File scope change | PASS/WARN/FAIL | ... |
| Tool/action mismatch | PASS/WARN/FAIL | ... |
| Plan deviation | PASS/WARN/FAIL | ... |
| Repeated failure signal | PASS/WARN/FAIL | ... |

**Overall: CONTINUE / REPLAN / ESCALATE**

Reason: <one sentence>
```
