#!/usr/bin/env bash
# Unified command palette — apps, shortcuts, WM actions, recent files, web search

RETV=${ROFI_RETV:-0}
INFO="$ROFI_INFO"
DATA="$ROFI_DATA"
NIRI_CFG="$HOME/.config/niri/config.kdl"
XBEL="$HOME/.local/share/recently-used.xbel"

# ─── URL decode (no python3 required) ─────────────────────────────
url_decode() {
    local encoded="${1//+/ }"
    printf '%b' "${encoded//%/\\x}"
}

# ─── Parse niri config for titled shortcuts ────────────────────────
parse_shortcuts() {
    [[ -f "$NIRI_CFG" ]] || return
    while IFS= read -r line; do
        # Skip the line that launches this very script
        echo "$line" | grep -q 'Command Palette' && continue

        key=$(echo "$line" | grep -oP '^\s*\K[^\s]+(?=\s+(hotkey|repeat))')
        title=$(echo "$line" | grep -oP 'hotkey-overlay-title="\K[^"]+')
        [[ -z "$title" || -z "$key" ]] && continue

        action=$(echo "$line" | grep -oP '\{\s*\K[^}]+')

        if echo "$action" | grep -qP 'spawn-sh\s+'; then
            cmd=$(echo "$action" | grep -oP 'spawn-sh\s+"\K[^"]+')
            printf "󰌌 %s  [%s]\0info\x1fsh:%s\n" "$title" "$key" "$cmd"
        elif echo "$action" | grep -q 'spawn'; then
            cmd=$(echo "$action" | grep -oP '"[^"]+"' | tr -d '"' | tr '\n' ' ' | xargs)
            printf "󱌣 %s  [%s]\0info\x1fspawn:%s\n" "$title" "$key" "$cmd"
        fi
    done < <(grep 'hotkey-overlay-title=' "$NIRI_CFG")
}

# ─── Recent files from xbel ───────────────────────────────────────
recent_files() {
    [[ -f "$XBEL" ]] || return
    grep -oP 'href="\Kfile://[^"]+' "$XBEL" | tac | head -12 | while read -r uri; do
        path=$(url_decode "${uri#file://}")
        name=$(basename "$path")
        if [[ -d "$path" ]]; then
            printf " %s\0info\x1fopen:%s\n" "$name" "$path"
        else
            printf " %s\0info\x1fopen:%s\n" "$name" "$path"
        fi
    done
}

# ─── File browser (called recursively via ROFI_DATA) ──────────────
browse_dir() {
    local dir="$1"
    printf "\0prompt\x1f %s\n" "$(basename "$dir")/"
    printf "\0data\x1fbrowse:%s\n" "$dir"
    printf "\0message\x1fEnter to open · select dir to navigate\n"

    if [[ "$dir" != "/" ]]; then
        printf "  .. (up)\0info\x1fbrowse:%s\n" "$(dirname "$dir")"
    fi

    # Dirs first, then files
    while IFS= read -r d; do
        printf "  %s/\0info\x1fbrowse:%s\n" "$(basename "$d")" "$d"
    done < <(find "$dir" -maxdepth 1 -mindepth 1 -type d ! -name '.*' | sort)

    while IFS= read -r f; do
        printf "  %s\0info\x1fopen:%s\n" "$(basename "$f")" "$f"
    done < <(find "$dir" -maxdepth 1 -mindepth 1 ! -type d ! -name '.*' | sort)
}

# ─── Main listing ─────────────────────────────────────────────────
list_all() {
    printf "\0prompt\x1fCommand\n"
    printf "\0data\x1f\n"
    printf "\0message\x1fEnter to run  ·  Ctrl+Tab → Apps / Cmds modes\n"

    # ── Shortcuts from niri config ─────────────────────────────────
    printf "── Shortcuts ────────────────────\0nonselectable\x1ftrue\n"
    parse_shortcuts

    # ── System ─────────────────────────────────────────────────────
    printf "── System ───────────────────────\0nonselectable\x1ftrue\n"
    printf "󰷛 Lock Screen\0info\x1fspawn:hyprlock\n"
    printf " Screenshot Region\0info\x1fniri:screenshot\n"
    printf "󰑘 Show Time\0info\x1fsh:notify-send Time \"$(date '+%H:%M  —  %A %d %B %Y')\"\n"
    printf " Hotkey Overlay\0info\x1fniri:show-hotkey-overlay\n"

    # ── Window / workspace navigation ─────────────────────────────
    printf "── Window Management ────────────\0nonselectable\x1ftrue\n"
    printf " Focus Left  [Mod+H]\0info\x1fniri:focus-column-left\n"
    printf " Focus Right  [Mod+L]\0info\x1fniri:focus-column-right\n"
    printf " Focus Down  [Mod+J]\0info\x1fniri:focus-window-or-workspace-down\n"
    printf " Focus Up  [Mod+K]\0info\x1fniri:focus-window-or-workspace-up\n"
    printf "󰩮 Close Window  [Mod+Q]\0info\x1fniri:close-window\n"
    printf "󰒉 Toggle Overview  [Mod+O]\0info\x1fniri:toggle-overview\n"
    printf " Workspace Down  [Mod+PgDn]\0info\x1fniri:focus-workspace-down\n"
    printf " Workspace Up  [Mod+PgUp]\0info\x1fniri:focus-workspace-up\n"
    printf " Move Col Left  [Mod+Shift+H]\0info\x1fniri:move-column-left\n"
    printf " Move Col Right  [Mod+Shift+L]\0info\x1fniri:move-column-right\n"
    printf " Move Win Down  [Mod+Shift+J]\0info\x1fniri:move-window-down-or-to-workspace-down\n"
    printf " Move Win Up  [Mod+Shift+K]\0info\x1fniri:move-window-up-or-to-workspace-up\n"
    printf "󰓡 Fullscreen  [Mod+Shift+F]\0info\x1fniri:fullscreen-window\n"
    printf " Center Column  [Mod+C]\0info\x1fniri:center-column\n"
    printf "󰜷 Expand Width  [Mod+=]\0info\x1fniri:set-column-width \"+10%\"\n"
    printf "󰜮 Shrink Width  [Mod+-]\0info\x1fniri:set-column-width \"-10%\"\n"
    printf "󰜻 Reset Width  [Mod+R]\0info\x1fniri:switch-preset-column-width\n"

    # ── Browse files ───────────────────────────────────────────────
    printf "── Browse ───────────────────────\0nonselectable\x1ftrue\n"
    printf " Home Directory\0info\x1fbrowse:%s\n" "$HOME"
    printf " Downloads\0info\x1fbrowse:%s/Downloads\n" "$HOME"
    printf " Projects\0info\x1fbrowse:%s/Projects\n" "$HOME"
    printf " Config\0info\x1fbrowse:%s/.config\n" "$HOME"
    printf " Nixos Config\0info\x1fbrowse:%s/nixos\n" "$HOME"

    # ── Recent files ──────────────────────────────────────────────
    printf "── Recent Files ─────────────────\0nonselectable\x1ftrue\n"
    recent_files

    # ── Web search ────────────────────────────────────────────────
    printf "── Search ───────────────────────\0nonselectable\x1ftrue\n"
    printf "󰇧 Search: %s\0info\x1fsearch:%s\n" "${DATA:-...}" "${DATA:-}"
}

# ─── Execute selection ────────────────────────────────────────────
execute() {
    local cmd="$1"
    case "$cmd" in
        spawn:*)
            eval "nohup ${cmd#spawn:} &>/dev/null &"
            ;;
        sh:*)
            eval "nohup bash -c '${cmd#sh:}' &>/dev/null &"
            ;;
        niri:*)
            # shellcheck disable=SC2086
            niri msg action ${cmd#niri:} &
            ;;
        open:*)
            xdg-open "${cmd#open:}" &
            ;;
        browse:*)
            browse_dir "${cmd#browse:}"
            return
            ;;
        search:*)
            local q="${cmd#search:}"
            if [[ -n "$q" ]]; then
                local enc
                enc=$(printf '%s' "$q" | jq -sRr @uri 2>/dev/null || python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$q" 2>/dev/null || echo "$q")
                brave "https://search.brave.com/search?q=${enc}" &
            fi
            ;;
    esac
}

# ─── Router ───────────────────────────────────────────────────────
case "$RETV" in
    0)
        # Check if we're in file browser mode
        if [[ "$DATA" == browse:* ]]; then
            browse_dir "${DATA#browse:}"
        else
            list_all
        fi
        ;;
    1|2)
        if [[ "$INFO" == browse:* ]]; then
            browse_dir "${INFO#browse:}"
        else
            execute "$INFO"
        fi
        ;;
esac
