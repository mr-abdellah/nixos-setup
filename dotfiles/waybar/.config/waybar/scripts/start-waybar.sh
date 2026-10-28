#!/usr/bin/env bash
# Supervise waybar: guarantee a single instance, restart it if it dies.
#
# Nix wraps the binary, so the process comm is ".waybar-wrapped" and
# `pkill -x waybar` silently matches nothing. Matching that way is why
# instances used to pile up on every restart. Match the command line instead.

set -u

WAYBAR=$(command -v waybar) || { echo "waybar not found on PATH" >&2; exit 1; }
CONFIG="$HOME/.config/waybar/config.jsonc"
STYLE="$HOME/.config/waybar/style.css"
PATTERN='/bin/waybar'   # matches the wrapped binary, not this script

# Stop any other supervisor, but never this one or its parent shell.
for pid in $(pgrep -f 'start-waybar\.sh' 2>/dev/null); do
    [ "$pid" = "$$" ] && continue
    [ "$pid" = "${PPID:-0}" ] && continue
    kill "$pid" 2>/dev/null
done

# Stop every running waybar, then wait for them to actually exit.
pkill -f "$PATTERN" 2>/dev/null
for _ in $(seq 30); do
    pgrep -f "$PATTERN" >/dev/null 2>&1 || break
    sleep 0.1
done
pkill -9 -f "$PATTERN" 2>/dev/null

while true; do
    "$WAYBAR" --config "$CONFIG" --style "$STYLE"
    sleep 1
done
