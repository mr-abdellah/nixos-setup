#!/usr/bin/env bash
# bluetooth-menu.sh — rofi Bluetooth manager via bluetoothctl

THEME="$HOME/.config/rofi/themes/popup.rasi"
ROFI="rofi -dmenu -theme $THEME -no-custom -i"

bt_powered() {
    bluetoothctl show 2>/dev/null | awk '/Powered:/{print $2}'
}

device_name() {
    bluetoothctl info "$1" 2>/dev/null | awk -F': ' '/^\tName:/{print $2}'
}

device_icon() {
    local icon_type
    icon_type=$(bluetoothctl info "$1" 2>/dev/null | awk -F': ' '/^\tIcon:/{print $2}')
    case "$icon_type" in
        input-keyboard)   echo "󰌌" ;;
        input-mouse)      echo "󰍽" ;;
        audio-headset)    echo "󰋎" ;;
        audio-headphones) echo "󰋋" ;;
        audio-card)       echo "󰓃" ;;
        phone)            echo "󰄜" ;;
        computer)         echo "󰇄" ;;
        *)                echo "󰂱" ;;
    esac
}

# ── Build menu ────────────────────────────────────────────────────────────────

powered=$(bt_powered)
entries=()

if [[ "$powered" == "yes" ]]; then
    entries+=("󰂲  Turn Bluetooth off")
    entries+=("─────────────────────────")

    # Connected devices first
    connected_macs=$(bluetoothctl devices Connected 2>/dev/null | awk '{print $2}')
    has_connected=0

    while IFS= read -r mac; do
        [[ -z "$mac" ]] && continue
        name=$(device_name "$mac")
        icon=$(device_icon "$mac")
        entries+=("$icon  $name  ✓  [$mac]")
        has_connected=1
    done <<< "$connected_macs"

    (( has_connected )) && entries+=("─────────────────────────")

    # All paired devices (not connected)
    while IFS= read -r line; do
        mac=$(echo "$line" | awk '{print $2}')
        [[ -z "$mac" ]] && continue
        # Skip already-connected ones
        echo "$connected_macs" | grep -q "$mac" && continue
        name=$(echo "$line" | cut -d' ' -f3-)
        icon=$(device_icon "$mac")
        trusted=$(bluetoothctl info "$mac" 2>/dev/null | awk '/Trusted:/{print $2}')
        entries+=("$icon  $name  [$mac]")
    done < <(bluetoothctl devices 2>/dev/null)

    entries+=("─────────────────────────")
    entries+=("󰐗  Scan for new devices")
    entries+=("󰣇  Open bluetui (full TUI)")
else
    entries+=("󰂯  Turn Bluetooth on")
fi

# ── Show menu ─────────────────────────────────────────────────────────────────

choice=$(printf '%s\n' "${entries[@]}" | $ROFI -p "Bluetooth")
[[ -z "$choice" ]] && exit 0

# ── Handle choice ─────────────────────────────────────────────────────────────

if [[ "$choice" == *"Turn Bluetooth off"* ]]; then
    bluetoothctl power off
    notify-send "Bluetooth" "Adapter turned off" -t 3000

elif [[ "$choice" == *"Turn Bluetooth on"* ]]; then
    bluetoothctl power on
    notify-send "Bluetooth" "Adapter turned on" -t 3000

elif [[ "$choice" == *"Scan for new devices"* ]]; then
    notify-send "Bluetooth" "Scanning for 10 seconds…" -t 4000
    kitty -e bash -c "bluetoothctl scan on & sleep 10; bluetoothctl scan off; bluetoothctl devices; read -p 'Press enter to close'"

elif [[ "$choice" == *"Open bluetui"* ]]; then
    kitty -e bluetui

elif [[ "$choice" =~ \[([0-9A-F:]{17})\] ]]; then
    mac="${BASH_REMATCH[1]}"
    name=$(device_name "$mac")

    if echo "$connected_macs" | grep -q "$mac"; then
        # Disconnect
        bluetoothctl disconnect "$mac"
        notify-send "Bluetooth" "Disconnected from $name" -t 3000
    else
        # Connect
        notify-send "Bluetooth" "Connecting to $name…" -t 3000
        if bluetoothctl connect "$mac" 2>/dev/null | grep -q "successful"; then
            notify-send "Bluetooth" "Connected to $name" -t 4000
        else
            notify-send "Bluetooth" "Failed to connect to $name" -u critical -t 5000
        fi
    fi
fi
