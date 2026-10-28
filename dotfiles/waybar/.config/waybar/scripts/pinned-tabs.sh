#!/usr/bin/env bash
# Reads Brave bookmarks bar and outputs waybar JSON buttons
# Each bookmark becomes a clickable icon that opens in Brave

BOOKMARKS="$HOME/.config/BraveSoftware/Brave-Browser/Default/Bookmarks"

if [[ ! -f "$BOOKMARKS" ]]; then
    echo "{\"text\": \"\", \"tooltip\": \"No bookmarks found\"}"
    exit 0
fi

# Build array of {name, url} from bookmarks bar
items=$(jq -r '
  .roots.bookmark_bar.children
  | .[]
  | select(.type == "url")
  | [.name, .url]
  | @tsv
' "$BOOKMARKS" 2>/dev/null)

if [[ -z "$items" ]]; then
    echo "{\"text\": \"\", \"tooltip\": \"No bookmarks bar items\"}"
    exit 0
fi

# Build a compact text with tooltip showing names
count=$(echo "$items" | wc -l)
echo "{\"text\": \"󰃃 $count\", \"tooltip\": \"$(echo "$items" | cut -f1 | head -8 | tr '\n' '\n' | sed 's/$/\\n/' | tr -d '\n')\", \"class\": \"pinned\"}"
