#!/usr/bin/env bash
# Spawn one Bar1 per connected monitor. The primary monitor (the one
# xrandr reports as "primary", falling back to the first connected
# output) gets the system tray; the rest run with TRAY_POSITION=none
# so only one polybar instance owns the tray.

killall -q polybar
while pgrep -x polybar >/dev/null; do sleep 0.2; done

primary=$(xrandr --query | awk '/ connected primary/ {print $1; exit}')
if [ -z "$primary" ]; then
    primary=$(xrandr --query | awk '/ connected/ {print $1; exit}')
fi

for m in $(xrandr --query | awk '/ connected/ {print $1}'); do
    if [ "$m" = "$primary" ]; then
        TRAY_POSITION=right MONITOR=$m polybar --reload Bar1 >/tmp/polybar-$m.log 2>&1 & disown
    else
        TRAY_POSITION=none MONITOR=$m polybar --reload Bar1 >/tmp/polybar-$m.log 2>&1 & disown
    fi
done
