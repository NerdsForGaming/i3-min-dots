# Changelog

All notable changes to this rice will be documented in this file.
Entries are grouped by version. The updater reads this file between
the locally installed `VERSION` and the freshly pulled one and shows
the user every entry in between. If nothing's listed, it reports
"bug fixes".

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.0.0] - 2026-06-11

### Added
- System tray in polybar (right side of primary monitor only).
- Rofi AppImages page — drop any `*.AppImage` into `~/appimages/`
  and launch it from `Mod+d` (Tab to switch tab).
- Installable rice repo at `~/rice/` with `install.sh`.
- `rice-update` (dotfiles only) and `rice-update-full`
  (dotfiles + `pacman -Syu` + `yay -Syu`) updaters.
- Startup update check (`rice-update-check`) — shows a themed rofi
  popup when a new version is available.
