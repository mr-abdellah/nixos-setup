#!/usr/bin/env bash
# Outputs waybar JSON for iwd wifi status

IFACE="wlan0"

# Strip ANSI escape codes then parse
raw=$(iwctl station "$IFACE" show 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g')

state=$(echo "$raw" | grep -m1 'State' | awk '{print $NF}')
ssid=$(echo "$raw" | grep 'Connected network' | sed 's/.*Connected network *//' | tr -d '[:space:]')
rssi=$(echo "$raw" | grep -m1 'RSSI' | grep -oE '\-?[0-9]+' | head -1)

if [[ "$state" == "connected" ]]; then
    if [[ -n "$rssi" ]]; then
        if (( rssi >= -50 )); then
            icon="󰤨"
        elif (( rssi >= -65 )); then
            icon="󰤥"
        elif (( rssi >= -75 )); then
            icon="󰤢"
        else
            icon="󰤟"
        fi
    else
        icon="󰤨"
    fi
    ip=$(ip addr show "$IFACE" 2>/dev/null | awk '/inet /{print $2}' | head -1)
    tooltip="${ssid}  ${rssi} dBm"
    [[ -n "$ip" ]] && tooltip="$tooltip\n$ip"
    echo "{\"text\": \"$icon  <span size='small'>$ssid</span>\", \"tooltip\": \"$tooltip\", \"class\": \"connected\"}"
else
    echo "{\"text\": \"󰤭\", \"tooltip\": \"Not connected\", \"class\": \"disconnected\"}"
fi
