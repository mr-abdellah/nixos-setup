#!/usr/bin/env bash
FILE="$HOME/.local/share/todo-widget/tasks.json"
[ -f "$FILE" ] || exit 0
jq '[.[] | select(.done == false)]' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
