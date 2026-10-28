#!/usr/bin/env bash

CLASS="$1"
shift
ID=$(niri msg windows | awk -v class="\"$CLASS\"" '
  /^Window ID/ { id=$3; gsub(/:/, "", id) }
  /App ID:/ && $NF == class { print id }
')
if [ -n "$ID" ]; then
  niri msg action close-window --id "$ID"
else
  "$@"
fi
