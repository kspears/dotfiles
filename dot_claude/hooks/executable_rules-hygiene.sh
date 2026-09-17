#!/bin/bash
# SessionStart hook — flags drift in auto-memory and permissions so Claude
# suggests a cleanup pass when thresholds are exceeded. Degrades silently
# if the project has no auto-memory dir or settings.local.json.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
SLUG=$(echo "$PROJECT_DIR" | tr '/' '-')  # /Users/kevin/code/homelab -> -Users-kevin-code-homelab

MEMORY_FILE="$HOME/.claude/projects/$SLUG/memory/MEMORY.md"
LOCAL_SETTINGS="$PROJECT_DIR/.claude/settings.local.json"

MEMORY_THRESHOLD=180
PERMS_THRESHOLD=120

warnings=()

if [ -f "$MEMORY_FILE" ]; then
  lines=$(wc -l <"$MEMORY_FILE" | tr -d ' ')
  if [ "$lines" -gt "$MEMORY_THRESHOLD" ]; then
    warnings+=("MEMORY.md is $lines lines (threshold $MEMORY_THRESHOLD) — close to the 200-line truncation boundary.")
  fi
fi

if [ -f "$LOCAL_SETTINGS" ] && command -v jq >/dev/null 2>&1; then
  count=$(jq -r '.permissions.allow | length // 0' "$LOCAL_SETTINGS" 2>/dev/null || echo 0)
  if [ "$count" -gt "$PERMS_THRESHOLD" ]; then
    warnings+=(".claude/settings.local.json has $count permission entries (threshold $PERMS_THRESHOLD) — likely has duplicates or stale one-offs.")
  fi
fi

if [ "${#warnings[@]}" -gt 0 ]; then
  echo "Rules hygiene check:"
  for w in "${warnings[@]}"; do
    echo "  - $w"
  done
  echo "  Consider a cleanup pass: prune stale entries, de-dupe, promote common permissions to global."
fi
