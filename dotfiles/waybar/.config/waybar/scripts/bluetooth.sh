#!/usr/bin/env bash
# Shows an icon per connected bluetooth device

powered=$(bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2}')

if [[ "$powered" != "yes" ]]; then
    echo "{\"text\": \"󰂲\", \"tooltip\": \"Bluetooth off\", \"class\": \"off\"}"
    exit 0
fi

devices=$(bluetoothctl devices Connected 2>/dev/null | awk '{print $2}')

if [[ -z "$devices" ]]; then
    echo "{\"text\": \"󰂯\", \"tooltip\": \"Bluetooth on, no devices\", \"class\": \"on\"}"
    exit 0
fi

icons=""
tooltip_lines=""

while IFS= read -r mac; do
    info=$(bluetoothctl info "$mac" 2>/dev/null)
    name=$(echo "$info" | awk -F': ' '/^\tName:/{print $2}')
    icon_type=$(echo "$info" | awk -F': ' '/^\tIcon:/{print $2}')

    case "$icon_type" in
        input-keyboard)   icon="󰌌" ;;
        input-mouse)      icon="󰍽" ;;
        audio-headset)    icon="󰋎" ;;
        audio-headphones) icon="󰋋" ;;
        audio-card)       icon="󰓃" ;;
        phone)            icon="󰄜" ;;
        computer)         icon="󰇄" ;;
        *)                icon="󰂱" ;;
    esac

    icons="$icons$icon "
    tooltip_lines="$tooltip_lines$icon  $name\n"
done <<< "$devices"

icons="${icons% }"
tooltip="${tooltip_lines%\\n}"

echo "{\"text\": \"$icons\", \"tooltip\": \"$tooltip\", \"class\": \"connected\"}"
