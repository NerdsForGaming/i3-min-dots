#!/usr/bin/env bash
# Rofi script-mode wallpaper picker.
# Lists image files under ~/Pictures (skipping Screenshots, Raws), and on
# selection sets the wallpaper via feh + regenerates the pywal palette.
#
# Wired up in ~/.config/rofi/config.rasi via the `wallpapers:` modi entry.

set -u

PIC_DIR="$HOME/Pictures"
MARKER="$HOME/.cache/last-wallpaper"

if [ -z "${1:-}" ]; then
    # Initial listing.
    [ -d "$PIC_DIR" ] || exit 0
    cd "$PIC_DIR"
    find . \
        \( -type d \( -iname Screenshots -o -iname Raws -o -iname .thumbnails \) -prune \) -o \
        -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
        -printf '%P\n' 2>/dev/null | sort
    exit 0
fi

# Selection: $1 is a path relative to ~/Pictures.
SELECTED="$PIC_DIR/$1"
[ -f "$SELECTED" ] || exit 0

feh --no-fehbg --bg-fill "$SELECTED" >/dev/null 2>&1 &

if command -v wal >/dev/null 2>&1; then
    wal -i "$SELECTED" -n -q >/dev/null 2>&1 &
fi

mkdir -p "$(dirname "$MARKER")"
ln -sfn "$SELECTED" "$MARKER"

exit 0
