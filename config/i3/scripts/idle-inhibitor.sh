#!/usr/bin/env bash
# Keeps X11's idle counter from advancing while:
#   - any window is in i3 fullscreen mode (movies, fullscreen games), or
#   - a gamepad event device is producing events.
# Both conditions trigger a synthetic key (XF86Launch9, ignored by everything)
# via xdotool, which resets the X server's idle/screensaver timer.

# Kill any previous instance via pidfile (re-run on i3 reload via exec_always).
PIDFILE="${XDG_RUNTIME_DIR:-/tmp}/idle-inhibitor.pid"
if [ -f "$PIDFILE" ]; then
    old=$(cat "$PIDFILE" 2>/dev/null)
    if [ -n "$old" ] && [ "$old" != "$$" ] && kill -0 "$old" 2>/dev/null; then
        kill -TERM "$old" 2>/dev/null
        sleep 0.2
    fi
fi
echo $$ > "$PIDFILE"

POKE() { xdotool key --clearmodifiers XF86Launch9 >/dev/null 2>&1; }

# Only clear the pidfile if we still own it — a newer instance may have replaced us.
release_pidfile() {
    [ "$(cat "$PIDFILE" 2>/dev/null)" = "$$" ] && rm -f "$PIDFILE"
}
cleanup() {
    trap - EXIT INT TERM
    release_pidfile
    pkill -TERM -P $$ 2>/dev/null
    exit 0
}
trap cleanup INT TERM
trap 'release_pidfile; pkill -TERM -P $$ 2>/dev/null' EXIT

# One background reader per attached joystick event device.
for dev in /dev/input/by-id/*-event-joystick; do
    [ -r "$dev" ] || continue
    (
        while true; do
            # Block until one input_event struct (24 bytes on 64-bit) arrives.
            if dd if="$dev" bs=24 count=1 status=none >/dev/null 2>&1; then
                POKE
            else
                sleep 5  # device vanished; back off before retrying
            fi
        done
    ) &
done

# Foreground: poll i3 tree for any fullscreen window every 30s.
while true; do
    sleep 30
    # fullscreen_mode == 1 AND a real window (workspaces also report 1 in i3).
    i3-msg -t get_tree 2>/dev/null \
        | jq -e '.. | objects | select(.fullscreen_mode? == 1 and (.window != null))' \
        >/dev/null 2>&1 && POKE
done
