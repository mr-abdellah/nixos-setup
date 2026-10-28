#!/usr/bin/env bash
# Usage: open-bookmark.sh <index>
# Opens the Nth bookmark bar item in Brave

INDEX="${1:-0}"
BOOKMARKS="/home/alauxui/.config/BraveSoftware/Brave-Browser/Default/Bookmarks"
JQ="/run/current-system/sw/bin/jq"
BRAVE="/run/current-system/sw/bin/brave"

url=$("$JQ" -r --argjson i "$INDEX" '
  .roots.bookmark_bar.children
  | [.[] | select(.type == "url")]
  | .[$i]
  | select(. != null)
  | .url
' "$BOOKMARKS" 2>/dev/null)

if [[ -n "$url" && "$url" != "null" ]]; then
    "$BRAVE" "$url" &
    disown
fi
