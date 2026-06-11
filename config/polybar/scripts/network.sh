#!/usr/bin/env bash
# Polybar network status — read by [module/network].
# Prints a glyph + short label. Uses Nerd Font icons.

state=$(nmcli -t -f STATE general status 2>/dev/null)

if [ "$state" != "connected" ] && [ "$state" != "connected (site only)" ] && [ "$state" != "connecting" ]; then
    printf '%s\n' "󰖪  off"
    exit 0
fi

# Active connection. Prefer wifi if both are up.
read -r wifi_name <<<"$(nmcli -t -f TYPE,NAME c show --active 2>/dev/null \
    | awk -F: '$1 == "802-11-wireless" {print $2; exit}')"
read -r eth_name <<<"$(nmcli -t -f TYPE,NAME c show --active 2>/dev/null \
    | awk -F: '$1 == "802-3-ethernet" {print $2; exit}')"

if [ -n "$wifi_name" ]; then
    # Signal strength of the connected AP.
    sig=$(nmcli -t -f IN-USE,SIGNAL d wifi 2>/dev/null \
          | awk -F: '$1 == "*" {print $2; exit}')
    case "${sig:-0}" in
        ''|0|[0-9]) bars="▂" ;;
        [1-3][0-9]) bars="▂▄" ;;
        [4-6][0-9]) bars="▂▄▆" ;;
        *)          bars="▂▄▆█" ;;
    esac
    # Truncate SSID at 14 chars to keep the bar compact.
    short="${wifi_name:0:14}"
    printf '%s\n' "  $bars $short"
elif [ -n "$eth_name" ]; then
    printf '%s\n' "󰈁  eth"
else
    printf '%s\n' "󰖪  off"
fi
