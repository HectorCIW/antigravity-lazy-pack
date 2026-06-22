#!/usr/bin/env bash
set -u

# Safe command wrapper with classification and logging.
# Usage: ./safe_run.sh "command here"
#        ./safe_run.sh --yes "command here"

AUTO_YES=0
if [ "${1:-}" = "--yes" ]; then
  AUTO_YES=1
  shift
fi

CMD="$*"
if [ -z "$CMD" ]; then
  echo "Usage: $0 [--yes] \"command here\"" >&2
  exit 2
fi

mkdir -p .agents
LOG_FILE=".agents/COMMAND_LOG.md"

classify() {
  local c="$1"
  if echo "$c" | grep -Eiq '(^|[;&|[:space:]])(rm[[:space:]]+-|rm[[:space:]]+-r|rm[[:space:]]+-rf|sudo|chmod[[:space:]]+-R|chown[[:space:]]+-R|git[[:space:]]+reset[[:space:]]+--hard|git[[:space:]]+clean[[:space:]]+-|git[[:space:]]+push[[:space:]].*--force|DROP[[:space:]]+TABLE|TRUNCATE[[:space:]]+TABLE|DELETE[[:space:]]+FROM)'; then
    echo "destructive"
  elif echo "$c" | grep -Eiq '(^|[;&|[:space:]])(curl|wget|git[[:space:]]+clone|git[[:space:]]+fetch|git[[:space:]]+pull|git[[:space:]]+push|npm[[:space:]]+install|pnpm[[:space:]]+install|yarn[[:space:]]+add|pip[[:space:]]+install|uv[[:space:]]+add|poetry[[:space:]]+add|brew[[:space:]]+install|docker[[:space:]]+pull|scp|rsync|ssh)'; then
    echo "network"
  elif echo "$c" | grep -Eiq '(^|[;&|[:space:]])(touch|mkdir|mv|cp|python|node|npm|pnpm|yarn|pytest|ruff|mypy|cargo|go|make|cmake|mvn|gradle|docker|git[[:space:]]+add|git[[:space:]]+commit|git[[:space:]]+checkout|git[[:space:]]+switch|git[[:space:]]+merge|sed[[:space:]]+-i)'; then
    echo "write"
  else
    echo "read-only"
  fi
}

CLASS="$(classify "$CMD")"
echo "Command: $CMD"
echo "Classification: $CLASS"

if [ "$CLASS" != "read-only" ] && [ "$AUTO_YES" -ne 1 ]; then
  printf "Proceed? Type yes to continue: "
  read -r ans
  if [ "$ans" != "yes" ]; then
    echo "Cancelled."
    exit 130
  fi
fi

START="$(date '+%Y-%m-%d %H:%M:%S %Z')"
TMP="$(mktemp)"
set +e
bash -lc "$CMD" >"$TMP" 2>&1
STATUS=$?
set -e
END="$(date '+%Y-%m-%d %H:%M:%S %Z')"

cat "$TMP"

{
  echo
  echo "## $START"
  echo "- Command: \`$CMD\`"
  echo "- Classification: $CLASS"
  echo "- Exit code: $STATUS"
  echo "- Finished: $END"
  echo "- Output tail:"
  echo '```text'
  tail -n 20 "$TMP" | sed -E 's/(sk-[A-Za-z0-9_-]{8})[A-Za-z0-9_-]+/\1...REDACTED/g; s/([A-Za-z0-9_]*TOKEN[A-Za-z0-9_]*[=:] ?)[^[:space:]]+/\1REDACTED/Ig; s/([A-Za-z0-9_]*SECRET[A-Za-z0-9_]*[=:] ?)[^[:space:]]+/\1REDACTED/Ig; s/([A-Za-z0-9_]*PASSWORD[A-Za-z0-9_]*[=:] ?)[^[:space:]]+/\1REDACTED/Ig; s/([A-Za-z0-9_]*API_KEY[A-Za-z0-9_]*[=:] ?)[^[:space:]]+/\1REDACTED/Ig'
  echo '```'
} >> "$LOG_FILE"

rm -f "$TMP"
exit "$STATUS"
