#!/usr/bin/env bash
# Polybar bluetooth status — read by [module/bluetooth].

if ! command -v bluetoothctl >/dev/null; then
    # Module is still shown so the user can click to learn how to
    # install bluez. The rofi handler walks them through it.
    printf '%s\n' "  install"
    exit 0
fi

# No controller present? Distinguish "off" vs "no adapter".
if ! bluetoothctl show 2>/dev/null | grep -q '^Controller'; then
    printf '%s\n' "󰂲  n/a"
    exit 0
fi

powered=$(bluetoothctl show 2>/dev/null | awk '/Powered:/ {print $2; exit}')
if [ "$powered" != "yes" ]; then
    printf '%s\n' "󰂲  off"
    exit 0
fi

connected=$(bluetoothctl devices Connected 2>/dev/null \
            | awk '{$1=$2=""; sub(/^  /,""); print; exit}')
if [ -n "$connected" ]; then
    short="${connected:0:14}"
    printf '%s\n' "  $short"
else
    printf '%s\n' "  on"
fi
