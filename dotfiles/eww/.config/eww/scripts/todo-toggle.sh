#!/usr/bin/env bash
FILE="$HOME/.local/share/todo-widget/tasks.json"
ID="$1"
[ -f "$FILE" ] || exit 0
jq --arg id "$ID" \
  'map(if .id == $id then .done = (.done | not) else . end)' \
  "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
