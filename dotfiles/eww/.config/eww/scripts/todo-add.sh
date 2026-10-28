#!/usr/bin/env bash
FILE="$HOME/.local/share/todo-widget/tasks.json"
TEXT="$1"
[ -z "$TEXT" ] && exit 0
mkdir -p "$(dirname "$FILE")"
[ -f "$FILE" ] || echo '[]' > "$FILE"
ID=$(date +%s%N)
jq --arg text "$TEXT" --arg id "$ID" \
  '. + [{id: $id, text: $text, done: false}]' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
