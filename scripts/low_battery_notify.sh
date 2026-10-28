#!/usr/bin/env bash

CHARGING=$(cat /sys/class/power_supply/BATT/status | grep Charging || true)
BATTERY_LEVEL=$(cat /sys/class/power_supply/BATT/capacity)

if [ "$BATTERY_LEVEL" -lt 20 ] && [ -z "$CHARGING" ]; then
    notify-send "Low Battery" "Battery level is at ${BATTERY_LEVEL}%!" -u critical
fi
