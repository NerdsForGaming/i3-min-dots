# Changelog

All notable changes to this rice will be documented in this file.
Entries are grouped by version. The updater reads this file between
the locally installed `VERSION` and the freshly pulled one and shows
the user every entry in between. If nothing's listed, it reports
"bug fixes".

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.2.0] - 2026-06-14

### Fixed
- i3 no longer throws the error nagbar on `Mod+d` / reload. Three
  upstream config bugs are gone:
  - Added the required `font` directive (`pango:JetBrains Mono 10`).
    i3 errored with "You did not specify required configuration
    option font" without it.
  - `Mod+d` / `F9` rofi launcher no longer passes `-modi
    "drun,appimages:…"` inline — i3's parser choked on the comma.
    The mode list lives in `~/.config/rofi/config.rasi`, so the
    binding is just `rofi -show drun` and the AppImages tab still
    works (Tab to switch).
  - Firefox shortcut rebound from `$mod+alt+w` to `$mod+Mod1+w` —
    i3 can't translate the literal string "alt" to a key symbol.

### Changed
- Display now stays on at all times. Replaced `xset s 300 -dpms`
  with `xset s off` + `xset -dpms` + `xset s noblank`, so the screen
  never blanks and the monitor never enters DPMS power-save. (Locking
  on system suspend via xss-lock is unchanged.)

## [1.1.1] - 2026-06-11

### Changed
- Rewrote the rofi wifi picker. Cleaner layout: action rows at the
  top (toggle / rescan / disconnect), a divider, then networks
  sorted by signal strength with a connection marker, signal-strength
  icon, fixed-width SSID, and a lock glyph for secured APs. SSIDs are
  round-tripped via a hidden lookup table so spaces, colons, and
  unicode are handled correctly.
- Rewrote the rofi bluetooth manager with the same layout (toggle /
  scan / device list, paired before discovered). New devices get
  paired + trusted before connect so reconnects are automatic.
- Bluetooth polybar module is now always visible. When `bluetoothctl`
  isn't installed it shows "  install" and the click handler offers
  to copy `sudo pacman -S bluez bluez-utils` to the clipboard.

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
