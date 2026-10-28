#!/usr/bin/env bash
# wifi-menu.sh — rofi WiFi manager via iwd

IFACE="wlan0"
THEME="$HOME/.config/rofi/themes/popup.rasi"
ROFI="rofi -dmenu -theme $THEME -no-custom -i"

strip_ansi() { sed 's/\x1b\[[0-9;]*m//g'; }

get_state() {
    iwctl station "$IFACE" show 2>/dev/null | strip_ansi \
        | grep -m1 'State' | awk '{print $NF}'
}

get_connected_ssid() {
    iwctl station "$IFACE" show 2>/dev/null | strip_ansi \
        | grep 'Connected network' | sed 's/.*Connected network *//' | xargs
}

signal_icon() {
    case $1 in
        4) echo "󰤨" ;;
        3) echo "󰤥" ;;
        2) echo "󰤢" ;;
        *) echo "󰤟" ;;
    esac
}

# ── Build menu ────────────────────────────────────────────────────────────────

state=$(get_state)
connected=$(get_connected_ssid)
entries=()

if [[ "$state" == "connected" && -n "$connected" ]]; then
    ip=$(ip addr show "$IFACE" 2>/dev/null | awk '/inet /{print $2}' | head -1)
    entries+=("󰤨  $connected${ip:+  ($ip)}")
    entries+=("󰤭  Disconnect from $connected")
    entries+=("─────────────────────────")
fi

# Scan and list networks
iwctl station "$IFACE" scan 2>/dev/null
sleep 0.8

while IFS= read -r line; do
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
    [[ "$line" =~ ^-+ ]] && continue
    [[ "$line" =~ "Network name" ]] && continue
    [[ "$line" =~ "Available" ]] && continue

    ssid=$(echo "$line" | sed 's/^[[:space:]>]*//' | awk '{
        # Remove last two fields (security + signal like "psk ****")
        n = NF
        while (n > 0 && $n ~ /^\*+$/) n--
        if (n > 0 && ($n == "psk" || $n == "open" || $n == "8021x")) n--
        result = ""
        for (i=1; i<=n; i++) result = result (i>1 ? " " : "") $i
        print result
    }' | xargs)
    stars=$(echo "$line" | grep -oE '\*+' | tail -1)
    icon=$(signal_icon ${#stars})

    [[ -z "$ssid" ]] && continue
    [[ "$ssid" == "$connected" ]] && continue  # already shown at top

    lock=$(echo "$line" | grep -qE '\bpsk\b|\b8021x\b' && echo " 󰌆" || echo "")
    entries+=("$icon  $ssid$lock")
done < <(iwctl station "$IFACE" get-networks 2>/dev/null | strip_ansi)

entries+=("─────────────────────────")
entries+=("󰣇  Open impala (full TUI)")

# ── Show menu ─────────────────────────────────────────────────────────────────

choice=$(printf '%s\n' "${entries[@]}" | $ROFI -p "Wi-Fi")
[[ -z "$choice" ]] && exit 0

# ── Handle choice ─────────────────────────────────────────────────────────────

if [[ "$choice" == *"Disconnect from"* ]]; then
    iwctl station "$IFACE" disconnect
    notify-send "Wi-Fi" "Disconnected from $connected" -t 3000

elif [[ "$choice" == *"Open impala"* ]]; then
    kitty -e impala

elif [[ "$choice" =~ ^[󰤨󰤥󰤢󰤟] ]]; then
    # Extract SSID (strip icon prefix and optional IP / lock suffix)
    ssid=$(echo "$choice" | sed 's/^[^ ]* *//' | sed 's/ *([^)]*)//' | sed 's/ *󰌆//' | xargs)
    [[ -z "$ssid" ]] && exit 0

    has_lock=$(echo "$choice" | grep -c '󰌆')

    if (( has_lock )); then
        pass=$(rofi -dmenu -theme "$THEME" -p "󰌆 $ssid" \
               -password -no-custom \
               -mesg "Enter Wi-Fi passphrase" \
               < /dev/null)
        [[ -z "$pass" ]] && exit 0
        notify-send "Wi-Fi" "Connecting to $ssid…" -t 3000
        if iwctl --passphrase "$pass" station "$IFACE" connect "$ssid" 2>/dev/null; then
            notify-send "Wi-Fi" "Connected to $ssid" -t 4000
        else
            notify-send "Wi-Fi" "Failed to connect to $ssid" -u critical -t 5000
        fi
    else
        notify-send "Wi-Fi" "Connecting to $ssid…" -t 3000
        if iwctl station "$IFACE" connect "$ssid" 2>/dev/null; then
            notify-send "Wi-Fi" "Connected to $ssid" -t 4000
        else
            notify-send "Wi-Fi" "Failed to connect to $ssid" -u critical -t 5000
        fi
    fi
fi
