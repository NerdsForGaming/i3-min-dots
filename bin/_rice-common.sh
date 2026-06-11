#!/usr/bin/env bash
# Common helpers sourced by rice-update*, rice-update-check, etc.
# Not intended to be run directly.

# Resolve the rice repo root by following the symlink we installed
# into ~/.local/bin/. Falls back to ~/rice/ if anything looks off.
_rice_root() {
    local self="${BASH_SOURCE[1]:-$0}"
    local real
    real=$(readlink -f "$self" 2>/dev/null || echo "$self")
    local dir
    dir=$(dirname "$real")
    # bin/ sits inside the repo root.
    if [ -f "$dir/../VERSION" ]; then
        (cd "$dir/.." && pwd)
    else
        echo "$HOME/rice"
    fi
}

RICE_DIR="$(_rice_root)"
[ -f "$RICE_DIR/rice.conf" ] && source "$RICE_DIR/rice.conf"

rice_local_version() {
    [ -f "$RICE_DIR/VERSION" ] && tr -d '[:space:]' < "$RICE_DIR/VERSION"
}

# Print the remote VERSION by asking the configured remote without
# fetching the whole repo. Quiet on error.
rice_remote_version() {
    [ -z "${RICE_REPO_URL:-}" ] && return 1
    case "$RICE_REPO_URL" in
        http*|git@*|ssh://*) : ;;
        *) return 1 ;;
    esac
    if (cd "$RICE_DIR" && git remote -v 2>/dev/null | grep -q .); then
        # Use the configured local remote — faster, uses ssh keys, etc.
        local sha
        sha=$(cd "$RICE_DIR" && git ls-remote origin "${RICE_BRANCH:-main}" 2>/dev/null | awk '{print $1}')
        [ -z "$sha" ] && return 1
        (cd "$RICE_DIR" && git show "$sha:VERSION" 2>/dev/null) | tr -d '[:space:]'
    else
        # No local clone with a remote: fetch the raw file over HTTP if
        # the URL looks like a GitHub-style repo.
        local raw_url
        case "$RICE_REPO_URL" in
            *github.com*)
                raw_url=$(printf '%s' "$RICE_REPO_URL" \
                    | sed -e 's#git@github.com:#https://raw.githubusercontent.com/#' \
                          -e 's#https://github.com/#https://raw.githubusercontent.com/#' \
                          -e 's#\.git$##')
                raw_url="$raw_url/${RICE_BRANCH:-main}/VERSION"
                curl -fsSL --max-time 5 "$raw_url" 2>/dev/null | tr -d '[:space:]'
                ;;
            *) return 1 ;;
        esac
    fi
}

# Print CHANGELOG.md entries strictly newer than $1 (the previous
# local version), reading from $RICE_DIR/CHANGELOG.md.
# Format expected: "## [X.Y.Z] - YYYY-MM-DD".
rice_changelog_between() {
    local from="$1"
    local changelog="$RICE_DIR/CHANGELOG.md"
    [ -f "$changelog" ] || return 1
    awk -v from="$from" '
        /^## \[/ {
            # Extract X.Y.Z from "## [X.Y.Z] - date"
            match($0, /\[([^]]+)\]/, m)
            ver = m[1]
            if (ver == from) { capturing = 0; exit }
            capturing = 1
            print
            next
        }
        capturing { print }
    ' "$changelog"
}
