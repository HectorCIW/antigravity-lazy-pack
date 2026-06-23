# Harness Engineer Rationale

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
2. Check whether the standard harness files exist (`AGENTS.md`, `PROJECT_STATUS.md`, `.agents/COMMAND_LOG.md`, `.agents/MISSION_ANCHOR.md`, `.agents/scripts/`).
3. Confirm that global reusable skills remain generic and project-specific rules stay inside the project.
4. Ensure safety rules are explicit.
5. Ensure run/test/build commands are documented.
6. Add only the smallest necessary project-specific extension.

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
