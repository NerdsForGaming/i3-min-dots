# rice

A grayscale i3 rice for Arch Linux. Configs for i3, polybar, rofi,
picom, kitty, alacritty, dunst, and eww, plus an installer and a
self-updater that prompts you on login when a new version ships.

## Install

```sh
git clone <repo-url> ~/rice
cd ~/rice
./install.sh
```

`install.sh` will:

- Install required + optional packages via `pacman` and `yay`.
- Back up any existing `~/.config/{i3,polybar,rofi,picom,kitty,alacritty,dunst,eww}`
  to `~/.config/_bak/<timestamp>/`.
- Symlink `~/rice/config/<name>` → `~/.config/<name>` for each of the above.
- Symlink `~/rice/bin/*` into `~/.local/bin/`.
- Create `~/appimages/` if it doesn't exist.
- Clone qylock (lockscreen + SDDM theme) if not already present.

After running it, your live configs are symlinks back to this repo, so
editing `~/.config/i3/config` is the same as editing
`~/rice/config/i3/config` — commit, push, done.

## AppImages

Drop any `*.AppImage` into `~/appimages/`. Open the rofi menu (`Mod+d`),
press **Tab** to flip to the "appimages" page, type to filter,
**Enter** to launch. Files don't need to be marked executable — the
launcher chmods them on first run.

## Updates

A login service (`rice-update-check`) compares your local `VERSION`
against the remote one. If they differ, a themed rofi popup appears
asking whether to update. You can also run either updater manually:

```sh
rice-update         # pull this repo + re-link configs
rice-update-full    # also runs pacman -Syu and yay -Syu
```

After an update, the changelog entries between your old and new
version are shown in a rofi window. If nothing changed in
`CHANGELOG.md`, it just reports "bug fixes".

## Configure

Edit `~/rice/rice.conf` to point the updater at your fork
(`RICE_REPO_URL`) or to change where AppImages live (`APPIMAGE_DIR`).
