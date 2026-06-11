#!/usr/bin/env bash
# bootstrap.sh — single command to install OR update the rice.
#
#   curl -fsSL https://raw.githubusercontent.com/NerdsForGaming/i3-min-dots/main/bootstrap.sh | bash
#
# If ~/rice already exists as a checkout of this repo, the script
# fast-forwards it and re-runs install.sh (acts as an updater).
# Otherwise it clones fresh and runs install.sh.

set -euo pipefail

REPO_URL="${RICE_REPO_URL:-https://github.com/NerdsForGaming/i3-min-dots.git}"
RICE_DIR="${RICE_DIR:-$HOME/rice}"
BRANCH="${RICE_BRANCH:-main}"

log()  { printf '\033[1;33m::\033[0m %s\n' "$*"; }
warn() { printf '\033[1;31m!!\033[0m %s\n' "$*" >&2; }
die()  { warn "$*"; exit 1; }

command -v git >/dev/null || die "git is required. Install it and re-run."

if [ -d "$RICE_DIR/.git" ]; then
    cur_url=$(git -C "$RICE_DIR" remote get-url origin 2>/dev/null || true)
    if [ "$cur_url" != "$REPO_URL" ] && [ -n "$cur_url" ]; then
        warn "$RICE_DIR points at $cur_url, not $REPO_URL."
        warn "Refusing to clobber. Move it aside or set RICE_DIR to a different path."
        exit 2
    fi
    log "Updating existing rice in $RICE_DIR"
    git -C "$RICE_DIR" fetch --quiet origin "$BRANCH"
    if ! git -C "$RICE_DIR" pull --ff-only --quiet origin "$BRANCH"; then
        warn "Fast-forward failed — you have local changes in $RICE_DIR."
        warn "Commit, stash, or move them aside, then re-run."
        exit 3
    fi
else
    if [ -e "$RICE_DIR" ]; then
        die "$RICE_DIR exists but isn't a git checkout. Move it aside first."
    fi
    log "Cloning $REPO_URL → $RICE_DIR"
    git clone --quiet --branch "$BRANCH" "$REPO_URL" "$RICE_DIR"
fi

log "Running install.sh"
"$RICE_DIR/install.sh"

log "All done. Restart i3 (Mod+Shift+R) to pick up the new configs."
