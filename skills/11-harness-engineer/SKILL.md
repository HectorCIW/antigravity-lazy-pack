---
name: harness-engineer
description: Use when creating, upgrading, auditing, or adapting the project harness itself: skills, AGENTS.md, PROJECT_STATUS.md, command logs, Mission Anchor, checkpoint scripts, escalation policy, validation scripts, safety rules, CI/test commands, bootstrap templates, and project-specific workflow standards.
---
# Harness Engineer

> For detailed design rationale and examples, read `references/rationale.md`.

## 1. Procedure
1. Start with `project-context-digest`.
2. If `.agents/scripts/checkpoint.sh` does not exist, bootstrap it (see Bootstraps). Also initialize `.agents/COMMAND_LOG.md` and `.agents/scripts/compliance_check.sh`.
3. Use `dependency-env-harness` to detect stack. Verify if `rtk` (Rust Token Killer) is installed. If not, prompt user to install via `curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh` and `rtk init --agent antigravity`.
4. Use `privacy-secret-guard` before reading sensitive data.
5. Write Mission Anchor before implementation.
6. Run `bash .agents/scripts/checkpoint.sh "before_<task>"` before medium/high risk operations.
7. After failure, use `failure-classifier`.
8. Prefer updating templates/status files over modifying source code.
9. Keep new skills narrow and triggerable.
10. Update project status with `docs-status-handoff`.

## 2. Bootstraps

### Checkpoint Script
```bash
mkdir -p .agents/checkpoints .agents/scripts
cat > .agents/scripts/checkpoint.sh << 'BASH_EOF'
#!/usr/bin/env bash
LABEL=${1:-"checkpoint"}
STAMP=$(date +"%Y-%m-%d_%H%M%S")
OUT_DIR=".agents/checkpoints"
mkdir -p "$OUT_DIR"
if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  git status --short > "$OUT_DIR/${STAMP}_${LABEL}_status.txt"
  git diff > "$OUT_DIR/${STAMP}_${LABEL}.patch"
  echo "Checkpoint saved: ${STAMP}_${LABEL}.patch"
else
  echo "Not a git repo."
fi
BASH_EOF
chmod +x .agents/scripts/checkpoint.sh
```

### Compliance Script
```bash
cat > .agents/scripts/compliance_check.sh << 'BASH_EOF'
#!/usr/bin/env bash
echo "--- Compliance Check ---"
[ -f .agents/MISSION_ANCHOR.md ] && echo "✅ MISSION_ANCHOR.md found" || echo "❌ MISSION_ANCHOR.md missing"
[ -f .agents/COMMAND_LOG.md ] && echo "✅ COMMAND_LOG.md found" || echo "❌ COMMAND_LOG.md missing"
[ -f .agents/scripts/checkpoint.sh ] && echo "✅ checkpoint.sh found" || echo "❌ checkpoint.sh missing"
BASH_EOF
chmod +x .agents/scripts/compliance_check.sh
```

## 3. Escalation Tiers

| Tier | Meaning | Agent behavior |
|---|---|---|
| **1: Inform** | Safe, reversible (reads, safe writes) | Proceed and log |
| **2: Confirm** | Risky, external, broad | Pause and request user approval |
| **3: Surrender** | Destructive, security risk, 3 fails | Stop and hand over |

## 4. Output Format
```markdown
## Harness engineer review
- Project type:
- Existing harness files:
- Missing pieces:
- Safety risks:
- Recommended changes:
- Files to edit:
- Validation plan:
```
