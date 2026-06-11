#!/usr/bin/env bash
# install.sh — bootstrap the rice on a fresh machine, or re-link it.
#
# Safe to re-run: existing ~/.config/<name> dirs get backed up to
# ~/.config/_bak/<timestamp>/ before symlinks replace them.

set -euo pipefail

RICE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=rice.conf
source "$RICE_DIR/rice.conf"

ts() { date +%Y%m%d-%H%M%S; }
log() { printf '\033[1;33m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;31m!!\033[0m %s\n' "$*" >&2; }

# ---------------------------------------------------------------- packages
REQUIRED_PKGS=(i3-wm polybar rofi picom kitty alacritty dunst
               feh pamixer brightnessctl playerctl maim xclip
               xss-lock i3lock notification-daemon
               jq ripgrep git)
OPTIONAL_PKGS=(eww ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols-mono
               papirus-icon-theme zsh starship eza bat fzf zoxide
               tmux autorandr dex python-pywal redshift hsetroot
               sddm quickshell)

install_pkgs() {
    if ! command -v pacman >/dev/null; then
        warn "pacman not found — skipping package install."
        return
    fi
    log "Installing required packages (sudo will prompt)..."
    sudo pacman -S --needed --noconfirm "${REQUIRED_PKGS[@]}" || \
        warn "Some required packages failed to install."

    if command -v yay >/dev/null; then
        log "Installing optional packages via yay..."
        yay -S --needed --noconfirm "${OPTIONAL_PKGS[@]}" || \
            warn "Some optional packages failed to install."
    else
        warn "yay not installed; skipping optional package install."
        warn "Optional packages: ${OPTIONAL_PKGS[*]}"
    fi
}

# ---------------------------------------------------------------- configs
link_configs() {
    local backup_root="$HOME/.config/_bak/$(ts)"
    mkdir -p "$backup_root"
    for name in "${RICE_CONFIGS[@]}"; do
        local src="$RICE_DIR/config/$name"
        local dst="$HOME/.config/$name"
        if [ ! -d "$src" ]; then
            warn "Missing source: $src — skipping."
            continue
        fi
        if [ -L "$dst" ]; then
            # Re-linking: just replace.
            rm "$dst"
        elif [ -e "$dst" ]; then
            log "Backing up existing $dst → $backup_root/"
            mv "$dst" "$backup_root/"
        fi
        ln -s "$src" "$dst"
        log "Linked $dst → $src"
    done
    rmdir "$backup_root" 2>/dev/null || true
}

# ---------------------------------------------------------------- bin
link_bin() {
    mkdir -p "$HOME/.local/bin"
    for f in "$RICE_DIR/bin/"*; do
        local base
        base=$(basename "$f")
        local dst="$HOME/.local/bin/$base"
        [ -L "$dst" ] && rm "$dst"
        [ -e "$dst" ] && mv "$dst" "$dst.bak.$(ts)"
        ln -s "$f" "$dst"
    done
    log "Linked rice scripts into ~/.local/bin/"
}

# ---------------------------------------------------------------- extras
ensure_appimages() {
    mkdir -p "$APPIMAGE_DIR"
    log "AppImage drop folder: $APPIMAGE_DIR"
}

install_qylock() {
    local qylock_dir="$HOME/.config/qylock"
    if [ -d "$qylock_dir/.git" ]; then
        log "qylock already cloned — skipping."
        return
    fi
    log "Cloning qylock..."
    git clone --depth 1 https://github.com/end-4/qylock.git "$qylock_dir" || {
        warn "qylock clone failed; lockscreen install skipped."
        return
    }
    warn "Run the qylock installers manually if you want SDDM + lockscreen:"
    warn "  ~/.config/qylock/quickshell.sh"
    warn "  ~/.config/qylock/sddm.sh"
}

# ---------------------------------------------------------------- main
main() {
    log "Installing rice from $RICE_DIR"
    install_pkgs
    link_configs
    link_bin
    ensure_appimages
    install_qylock
    log "Done. Restart i3 (Mod+Shift+R) to pick up the new configs."
}

main "$@"
