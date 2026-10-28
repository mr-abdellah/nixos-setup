#!/usr/bin/env bash
if systemctl --user is-active --quiet wlsunset.service; then
    echo '{"text": "󱩌", "tooltip": "Night light: On — click to disable", "class": "on"}'
else
    echo '{"text": "󱩌", "tooltip": "Night light: Off — click to enable", "class": "off"}'
fi
