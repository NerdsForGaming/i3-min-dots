# Changelog

All notable changes to this rice will be documented in this file.
Entries are grouped by version. The updater reads this file between
the locally installed `VERSION` and the freshly pulled one and shows
the user every entry in between. If nothing's listed, it reports
"bug fixes".

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.1.0] - 2026-06-11

### Added
- One-line bootstrap installer (`bootstrap.sh`) that clones the rice
  on a fresh machine or fast-forwards an existing checkout.
- Themed polybar `network` module (wifi SSID + signal bars or `eth`)
  with a rofi-based picker that handles WPA password prompts.
- Themed polybar `bluetooth` module + rofi manager (scan, pair,
  connect, disconnect). Hidden until `bluez` is installed.

### Changed
- `nm-applet` tray icon suppressed via `~/.config/autostart/nm-applet.desktop`
  override — the polybar network module replaces it.
- `modules-right` order now `… date · network · bluetooth · power`,
  so the network indicator sits just left of the power button instead
  of getting buried in the system tray.

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
