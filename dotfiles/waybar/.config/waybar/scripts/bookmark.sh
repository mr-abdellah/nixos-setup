#!/usr/bin/env bash
# Usage: bookmark.sh <index>
# Returns waybar JSON for the Nth bookmark bar item

INDEX="${1:-0}"
BOOKMARKS="/home/alauxui/.config/BraveSoftware/Brave-Browser/Default/Bookmarks"
JQ="/run/current-system/sw/bin/jq"

item=$("$JQ" -r --argjson i "$INDEX" '
  .roots.bookmark_bar.children
  | [.[] | select(.type == "url")]
  | .[$i]
  | select(. != null)
  | [.name, .url]
  | @tsv
' "$BOOKMARKS" 2>/dev/null)

if [[ -z "$item" ]]; then
    echo ""
    exit 0
fi

name=$(echo "$item" | cut -f1)
url=$(echo "$item" | cut -f2)

icon="󰖟"
case "$url" in
    *github*)             icon="" ;;
    *posthog*)            icon="󰒊" ;;
    *google*)             icon="" ;;
    *notion*)             icon="󱓩" ;;
    *figma*)              icon="" ;;
    *linear*)             icon="󰏆" ;;
    *slack*)              icon="󰒱" ;;
    *youtube*)            icon="" ;;
    *twitter*|*x.com*)   icon="" ;;
    *claude*)             icon="󰧑" ;;
    *localhost*|*127.0.0.1*) icon="󰒍" ;;
esac

echo "{\"text\": \"$icon\", \"tooltip\": \"$name\\n$url\", \"class\": \"bookmark\"}"
