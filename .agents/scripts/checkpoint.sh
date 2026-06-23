#!/usr/bin/env bash
# Usage: bash .agents/scripts/checkpoint.sh "label"
LABEL=${1:-"checkpoint"}
STAMP=$(date +"%Y-%m-%d_%H%M%S")
OUT_DIR=".agents/checkpoints"
mkdir -p "$OUT_DIR"
if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  git status --short > "$OUT_DIR/${STAMP}_${LABEL}_status.txt"
  git diff > "$OUT_DIR/${STAMP}_${LABEL}.patch"
  echo "Checkpoint saved: ${STAMP}_${LABEL}.patch"
else
  echo "Not a git repo — initialize git first."
fi
