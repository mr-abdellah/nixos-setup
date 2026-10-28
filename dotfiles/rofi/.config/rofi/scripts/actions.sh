#!/usr/bin/env bash
# Rofi script mode: niri shortcuts + quick actions + web search

RETV=${ROFI_RETV:-0}

list_actions() {
    printf "\0prompt\x1fActions\n"
    printf "\0message\x1fCtrl+Tab to switch mode (Apps / Commands / Actions)\n"

    # ── Launchers ────────────────────────────────────────────────
    printf " Terminal\0info\x1fkitty\n"
    printf " Browser\0info\x1fbrave\n"
    printf " File Manager\0info\x1fkitty -e yazi\n"
    printf " App Launcher\0info\x1fkitty --class kitty-float -e tv cmds\n"
    printf " Files (tv)\0info\x1fkitty --class kitty-float-files -e tv files\n"

    # ── Tools ─────────────────────────────────────────────────────
    printf " Clipboard History\0info\x1fkitty --class kitty-float -e tv clipboard\n"
    printf " Passwords\0info\x1fkitty --class kitty-float-pass -e tv passwords\n"
    printf " Wifi\0info\x1fkitty --class kitty-float -e impala\n"
    printf " Bluetooth\0info\x1fkitty --class kitty-float -e bluetui\n"
    printf " Quick Notes\0info\x1fbrave --app=http://127.0.0.1:7777\n"
    printf " Todo\0info\x1fbrave --app=file:///home/alauxui/.local/share/todo-widget/index.html\n"
    printf " Opencode Sessions\0info\x1fkitty --class kitty-float -e tv opencode-sessions\n"

    # ── System ────────────────────────────────────────────────────
    printf "󰷛 Lock Screen\0info\x1fhyprlock\n"
    printf " Screenshot Region\0info\x1fniri msg action screenshot\n"
    printf "󱄅 Show Time\0info\x1fnotify-send Time \"$(date '+%H:%M  —  %A %d %B %Y')\"\n"
    printf " Hotkey Overlay\0info\x1fniri msg action show-hotkey-overlay\n"

    # ── Keybind reference ─────────────────────────────────────────
    printf "\n── Keybinds ─────────────────────\0nonselectable\x1ftrue\n"
    printf "Mod+T  → Terminal\0nonselectable\x1ftrue\n"
    printf "Mod+B  → Browser\0nonselectable\x1ftrue\n"
    printf "Mod+E  → yazi\0nonselectable\x1ftrue\n"
    printf "Mod+D  → App Launcher\0nonselectable\x1ftrue\n"
    printf "Mod+F  → Files\0nonselectable\x1ftrue\n"
    printf "Mod+P  → Passwords\0nonselectable\x1ftrue\n"
    printf "Mod+Shift+C  → Clipboard\0nonselectable\x1ftrue\n"
    printf "Mod+I  → Wifi\0nonselectable\x1ftrue\n"
    printf "Mod+Shift+B  → Bluetooth\0nonselectable\x1ftrue\n"
    printf "Mod+N  → Todo\0nonselectable\x1ftrue\n"
    printf "Mod+Shift+N  → Quick Notes\0nonselectable\x1ftrue\n"
    printf "Mod+X  → Lock\0nonselectable\x1ftrue\n"
    printf "Mod+Shift+S  → Screenshot\0nonselectable\x1ftrue\n"

    # ── Web search ────────────────────────────────────────────────
    printf "\n── Search ───────────────────────\0nonselectable\x1ftrue\n"
    printf "󰇧 Search: %s\0info\x1fsearch:%s\n" "${ROFI_DATA:-...}" "${ROFI_DATA:-}"
}

execute_action() {
    local cmd="$1"
    case "$cmd" in
        search:*)
            query="${cmd#search:}"
            if [[ -n "$query" ]]; then
                brave "https://search.brave.com/search?q=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$query")" &
            fi
            ;;
        "niri msg"*)
            eval "$cmd" &
            ;;
        *)
            eval "nohup $cmd &>/dev/null &"
            ;;
    esac
}

case "$RETV" in
    0)
        list_actions
        ;;
    1|2)
        info="$ROFI_INFO"
        execute_action "$info"
        ;;
esac
