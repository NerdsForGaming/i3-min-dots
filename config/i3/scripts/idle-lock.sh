#!/usr/bin/env bash
# Invoked by xss-lock on idle. Turns off eDP-1, runs the quickshell lock on HDMI-1-0.
# When lock exits (user authenticated), re-enables eDP-1.

LOCKSCREEN="$HOME/.local/share/quickshell-lockscreen/lock.sh"
INTERNAL="eDP-1"
EXTERNAL="HDMI-1-0"

restore() {
    xrandr \
        --output "$INTERNAL" --mode 1920x1080 --rate 144 --pos 0x0 \
        --output "$EXTERNAL" --mode 1920x1080 --rate 240 --pos 1920x0 --primary
    # Re-apply wallpaper and respawn polybars so bars re-attach to both outputs.
    feh --no-fehbg --bg-fill "$HOME/Pictures/Wallpapers/glt.png" >/dev/null 2>&1
    "$HOME/.config/polybar/launch.sh" >/dev/null 2>&1
}
trap restore EXIT INT TERM

xrandr --output "$INTERNAL" --off
"$LOCKSCREEN"
