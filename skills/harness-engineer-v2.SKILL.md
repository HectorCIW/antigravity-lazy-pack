---
name: harness-engineer
description: Use when creating, upgrading, auditing, or adapting the project harness itself: skills, AGENTS.md, PROJECT_STATUS.md, command logs, Mission Anchor, checkpoint scripts, escalation policy, validation scripts, safety rules, CI/test commands, bootstrap templates, and project-specific workflow standards.
---
# Harness Engineer

## Goal
Maintain a reusable, safe, project-neutral operating harness that lets Antigravity work consistently across repositories without resetting the workflow each time.

## When to use
Use this skill when the user asks to:
- set up a new project from the universal starter pack
- adapt the starter pack to a specific repository
- add or revise skills
- improve command safety, logging, testing, or project handoff
- audit whether the current project has a complete agent harness
- create project-specific extensions without polluting the global starter

## Core responsibilities
1. Inspect the current repository structure and detect the stack.
2. Check whether the standard harness files exist:
   - `AGENTS.md`
   - `PROJECT_STATUS.md`
   - `.agents/COMMAND_LOG.md`
   - `.agents/MISSION_ANCHOR.md` (written at task start by scope-drift-detector)
   - `.agents/checkpoints/` (created by checkpoint script before risky operations)
   - `.agents/scripts/checkpoint.sh` (see Checkpoint procedure below)
   - `.agents/scripts/` for dynamic helper scripts
   - optional `.agents/skills/` for project-local skills
3. Confirm that global reusable skills remain generic and project-specific rules stay inside the project.
4. Ensure safety rules are explicit for terminal commands, Git operations, secrets, data files, and generated outputs.
5. Ensure run/test/build commands are documented.
6. Add only the smallest necessary project-specific extension.

## Universal harness checklist
A healthy project should have:
- a clear project purpose in `PROJECT_STATUS.md`
- run and test commands, or a note that they are not known yet
- safety constraints in `AGENTS.md` (including the Autonomous Safety Policy)
- command logging through `.agents/COMMAND_LOG.md`
- a Mission Anchor written before each task in `.agents/MISSION_ANCHOR.md`
- a checkpoint script at `.agents/scripts/checkpoint.sh`
- code/data/docs workflow rules where relevant
- explicit protected files or directories when needed
- no secrets, credentials, or private data copied into status files

## Procedure
1. Start with `project-context-digest` to understand the project.
2. Use `dependency-env-harness` to detect the stack and likely commands.
3. Use `privacy-secret-guard` before reading config, logs, `.env`, credentials, or private data.
4. Write the Mission Anchor (`scope-drift-detector`) before any implementation begins.
5. Propose a small harness change before editing files.
6. Before any risky operation, run the checkpoint script (see below).
7. After any failure, use `failure-classifier` before retrying.
8. Prefer updating templates/status files over modifying source code.
9. If creating a new skill, keep it narrow, named clearly, and triggerable from its description.
10. After changes, use `docs-status-handoff` to update project status.

## Checkpoint procedure

Bootstrap the checkpoint script into every project:

```bash
mkdir -p .agents/checkpoints .agents/scripts
cat > .agents/scripts/checkpoint.sh << 'EOF'
#!/usr/bin/env bash
# Usage: bash .agents/scripts/checkpoint.sh "before_config_change"
LABEL=${1:-"checkpoint"}
STAMP=$(date +"%Y-%m-%d_%H%M%S")
OUT_DIR=".agents/checkpoints"
mkdir -p "$OUT_DIR"
if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  git status --short > "$OUT_DIR/${STAMP}_${LABEL}_status.txt"
  git diff > "$OUT_DIR/${STAMP}_${LABEL}.patch"
  echo "Checkpoint saved: ${STAMP}_${LABEL}.patch"
else
  echo "Not a git repo — copying touched files not implemented. Initialize git first."
fi
EOF
chmod +x .agents/scripts/checkpoint.sh
```

Call the checkpoint script before any medium or high-risk operation:

```bash
bash .agents/scripts/checkpoint.sh "before_<operation_name>"
```

Risk classification for checkpoints:

| Risk level | Examples | Action |
|---|---|---|
| Low | Edit 1–2 in-scope source files, update docs | No checkpoint needed |
| Medium | Config change, dependency install, rename/delete, edit >3 files | Patch checkpoint |
| High | Destructive command, firmware flash, production deploy, CI/CD change, `.env` edit | Checkpoint + Tier 2 confirmation |

## Escalation tiers

| Tier | Meaning | Agent behavior |
|---|---|---|
| **Tier 1: Inform** | Safe, reversible, in-scope (read-only or approved low-risk writes) | Proceed and log |
| **Tier 2: Confirm** | Risky, external, broad, or semi-reversible | Pause and request user approval |
| **Tier 3: Surrender** | Destructive, security-sensitive, unknown, or repeatedly failing | Stop and hand over full context |

**Tier 1 examples:** read files, run tests/linters, inspect git status, edit 1–2 clearly in-scope files, update PROJECT_STATUS.md.

**Tier 2 examples:** install packages, modify requirements/package.json/pyproject.toml, change config files, edit >3 files, rename/delete files, access files outside workspace, call external APIs, modify MCP config, change database schema.

**Tier 3 examples:** `rm -rf`, `sudo`, `chmod -R`, `git reset --hard`, `git clean -fd`, force push, production deployment, firmware flashing, exposing secrets, editing `.env` with real keys, handling private clinical data, same failure after 3 attempts.

## Separation rules
- Put universal skills in `~/.gemini/config/skills/`.
- Put project-specific skills in `<project-root>/.agents/skills/`.
- Put project-specific facts in `PROJECT_STATUS.md`, not in global skills.
- Put agent behavior rules in `AGENTS.md`.
- Put command history in `.agents/COMMAND_LOG.md`.

## Do not
- Do not create broad, overlapping skills that duplicate existing harnesses.
- Do not add domain-specific content to the universal starter unless it applies to most projects.
- Do not weaken destructive-command confirmations.
- Do not copy secrets into templates, logs, or status files.
- Do not overwrite existing project-specific instructions without preserving or summarizing them.

## Output format
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
