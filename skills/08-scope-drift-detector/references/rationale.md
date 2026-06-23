# Scope Drift Detector Rationale

## Purpose
Distinguish between *doing too much of the right thing* (overbaking) and *doing the wrong thing entirely* (scope drift). Cosine similarity alone cannot catch operational drift — for example, searching for a plausible-sounding package that was never verified. This skill implements a structured Mission Anchor check and a multi-dimensional drift score.

## Step 3 — Drift recovery actions

| Drift level | Action |
|---|---|
| WARN | Log the anomaly. Continue. Flag for next check. |
| FAIL (recoverable) | Stop. Re-read Mission Anchor. Restate the current plan. Adjust and continue. |
| FAIL (ambiguous intent) | Stop. Summarize what the agent has tried and why it is stuck. Ask the user for clarification. |
| FAIL (out-of-scope action completed) | Trigger Checkpoint & Rollback. Escalate to Tier 2 or Tier 3. |

## Integration with other components
- **Project Orchestrator**: Writes the Mission Anchor at task start.
- **Loop Executor**: Calls drift re-check every 3 iterations.
- **Failure Classifier**: Feeds the "repeated failure signal" dimension.
- **Human Escalation Protocol**: Receives drift FAILs that require user input.
- **Checkpoint & Rollback**: Triggered when an out-of-scope action was already taken.
