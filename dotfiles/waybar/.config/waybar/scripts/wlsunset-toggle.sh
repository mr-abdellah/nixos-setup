#!/usr/bin/env bash
if systemctl --user is-active --quiet wlsunset.service; then
    systemctl --user stop wlsunset.service
else
    systemctl --user start wlsunset.service
fi
