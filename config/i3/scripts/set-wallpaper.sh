#!/usr/bin/env bash
# Applies the most recently selected wallpaper, falling back to the default.
# Called from i3 autostart so the wallpaper picked via rofi persists across
# i3 reloads / logins.

set -u

MARKER="$HOME/.cache/last-wallpaper"
DEFAULT="$HOME/Pictures/Wallpapers/glt.png"

if [ -L "$MARKER" ] && [ -f "$(readlink -f "$MARKER")" ]; then
    WP="$(readlink -f "$MARKER")"
elif [ -f "$DEFAULT" ]; then
    WP="$DEFAULT"
else
    exit 0
fi

feh --no-fehbg --bg-fill "$WP" >/dev/null 2>&1
