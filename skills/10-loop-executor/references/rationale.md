# Loop Executor Rationale

## Purpose
Transforms a multi-step plan into a governed execution loop. Without this skill, drift checks and failure classification depend on the agent remembering to trigger them — which is unreliable. This skill makes those triggers mechanical, not discretionary.

## Integration with other components
- **Project Orchestrator (Layer 1)**: Writes the Mission Anchor and hands off to Loop Executor.
- **scope-drift-detector (Layer 4)**: Called every 3 iterations and on risk signals.
- **failure-classifier (Layer 5)**: Called before every retry.
- **harness-engineer**: Bootstraps the checkpoint script before the loop starts.
- **docs-status-handoff (Layer 6)**: Called on successful loop termination.

## Minimal overhead note
This skill does not require reading the full skill file on every iteration. The agent only needs to:
1. Maintain the Loop State block in `MISSION_ANCHOR.md`.
2. Know the two trigger numbers: **every 3 iterations** and **after 2 consecutive failures**.
