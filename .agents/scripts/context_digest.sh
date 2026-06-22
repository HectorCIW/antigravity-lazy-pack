#!/usr/bin/env bash
set -u

# Read-only project digest for Antigravity starter pack.
# Usage: ./context_digest.sh [project_root]

ROOT="${1:-$(pwd)}"
cd "$ROOT" 2>/dev/null || { echo "Cannot cd into $ROOT" >&2; exit 1; }

redact() {
  sed -E 's/(sk-[A-Za-z0-9_-]{8})[A-Za-z0-9_-]+/\1...REDACTED/g; s/([A-Za-z0-9_]*TOKEN[A-Za-z0-9_]*[=:] ?)[^[:space:]]+/\1REDACTED/Ig; s/([A-Za-z0-9_]*SECRET[A-Za-z0-9_]*[=:] ?)[^[:space:]]+/\1REDACTED/Ig; s/([A-Za-z0-9_]*PASSWORD[A-Za-z0-9_]*[=:] ?)[^[:space:]]+/\1REDACTED/Ig; s/([A-Za-z0-9_]*API_KEY[A-Za-z0-9_]*[=:] ?)[^[:space:]]+/\1REDACTED/Ig'
}

section() { printf '\n## %s\n' "$1"; }

printf '# Project digest\n'
printf -- '- Time: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
printf -- '- Workspace: %s\n' "$(pwd)"

section "Project files"
for f in PROJECT_STATUS.md AGENTS.md README.md pyproject.toml package.json Cargo.toml go.mod; do
  [ -f "$f" ] && printf -- '- %s\n' "$f"
done

section "Detected stack"
[ -f pyproject.toml ] || [ -f requirements.txt ] || [ -f setup.py ] || [ -f uv.lock ] || [ -f poetry.lock ] && echo "- Python"
[ -f package.json ] && echo "- Node/JavaScript/TypeScript"
[ -f Cargo.toml ] && echo "- Rust"
[ -f go.mod ] && echo "- Go"
[ -f pom.xml ] || [ -f build.gradle ] || [ -f gradlew ] && echo "- Java/Kotlin"
[ -f CMakeLists.txt ] || [ -f Makefile ] && echo "- C/C++ or Make-based"
find . -maxdepth 2 -name '*.m' -o -name '*.mlx' 2>/dev/null | head -n 1 | grep -q . && echo "- MATLAB"

section "Git"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git status --short --branch 2>/dev/null | redact
  echo
  echo "Recent commits:"
  git log --since="24 hours ago" --oneline --decorate --all --max-count=20 2>/dev/null | redact || true
else
  echo "- Not a Git repository or Git unavailable."
fi

section "Files changed in last 24 hours"
find . \
  -path './.git' -prune -o \
  -path './node_modules' -prune -o \
  -path './.venv' -prune -o \
  -path './venv' -prune -o \
  -path './__pycache__' -prune -o \
  -type f -mtime -1 -print 2>/dev/null | sed 's#^./##' | sort | head -n 80 | redact

section "TODO / FIXME / HACK"
if command -v rg >/dev/null 2>&1; then
  rg -n --hidden --glob '!.git' --glob '!node_modules' --glob '!.venv' --glob '!venv' --glob '!.agents/scripts' --glob '!.agents/skills' 'TODO|FIXME|HACK' . 2>/dev/null | head -n 50 | redact || true
else
  grep -RIn --exclude-dir=.git --exclude-dir=node_modules --exclude-dir=.venv --exclude-dir=venv --exclude-dir=.agents -E 'TODO|FIXME|HACK' . 2>/dev/null | head -n 50 | redact || true
fi

section "Recent command log"
if [ -f .agents/COMMAND_LOG.md ]; then
  tail -n 80 .agents/COMMAND_LOG.md | redact
else
  echo "- No .agents/COMMAND_LOG.md found."
fi

section "Recommended next prompt"
echo "Ask: Use project-context-digest and propose the next three safe actions."
