#!/usr/bin/env bash
FILE="$HOME/.local/share/todo-widget/tasks.json"
DATE_FILE="$HOME/.local/share/todo-widget/date"
TODAY=$(date +%Y-%m-%d)

mkdir -p "$(dirname "$FILE")"

if [ -f "$DATE_FILE" ] && [ "$(cat "$DATE_FILE")" != "$TODAY" ]; then
  rm -f "$FILE"
fi

echo "$TODAY" > "$DATE_FILE"
[ -f "$FILE" ] || echo '[]' > "$FILE"
cat "$FILE"
