#!/usr/bin/env bash
# Polybar bluetooth status — read by [module/bluetooth].
# Silently no-ops if bluetoothctl isn't installed.

if ! command -v bluetoothctl >/dev/null; then
    printf '%s\n' ""
    exit 0
fi

powered=$(bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2; exit}')
if [ "$powered" != "yes" ]; then
    printf '%s\n' "󰂲  off"
    exit 0
fi

# Connected device name, if any.
connected=$(bluetoothctl devices Connected 2>/dev/null \
            | awk '{$1=$2=""; sub(/^  /,""); print; exit}')
if [ -n "$connected" ]; then
    short="${connected:0:14}"
    printf '%s\n' "  $short"
else
    printf '%s\n' "  on"
fi
