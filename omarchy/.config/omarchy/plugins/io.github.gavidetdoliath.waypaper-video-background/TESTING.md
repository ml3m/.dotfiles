# Testing

## Local release verification

Verified on 2026-08-16 with Omarchy 4.0.0:

- `omarchy plugin validate` passes for the repository root.
- `qmllint` passes with the installed Omarchy Shell import path.
- `bash -n` passes for all shell entry points.
- The mixed selector resolves current-theme images, per-theme user images, and
  Waypaper media folders; `--check` reports images and videos separately.
- A missing optional per-theme user background directory does not abort media
  discovery.
- The last selector row is an `Add` action with the bundled plus-sign
  thumbnail and resolves to
  `~/.config/omarchy/backgrounds/<current-theme>/`.
- Video thumbnails are generated once with `ffmpegthumbnailer` and reused from
  the plugin cache.
- The selector integration installs and removes its marked JSONC override
  without changing the surrounding menu extension.
- Re-running the integration installer upgrades the managed menu block while
  retaining Omarchy's `background` and `wallpaper` route aliases.
- The integration round trip restores both the user menu and Hyprland binding
  files byte-for-byte and removes only its managed `theme-set` hook.
- The theme synchronization `--check` resolves the current Omarchy background
  and configured Waypaper monitor without changing either one.
- `start-mpvpaper.sh --check` resolves an isolated Waypaper fixture without
  starting a renderer.
- `omarchy plugin add file://... --yes` and installation from the public
  `https://github.com/GavidetDoliath/omarchy-waypaper-video-background.git`
  URL both clone into an isolated HOME using the permanent manifest ID.
- The installed checkout has the same commit as its source, the expected Git
  origin, and a clean worktree.
- `omarchy plugin update <id> --yes` recognizes the clone as up to date.
- `omarchy plugin remove <id> --yes` removes the isolated Git checkout.
- A clean reinstall succeeds after removal and does not create `shell.json`.

The install lifecycle uses a test-only `omarchy-shell` stub so the live user
shell is neither rescanned nor reconfigured.

## Additional compatibility matrix

These checks extend the verified single-machine release coverage:

- [x] Existing local Waypaper configuration resolves successfully.
- [x] Manifest, QML, and shell syntax validation.
- [x] Isolated Git add, update, remove, and reinstall lifecycle.
- [x] Install, update, remove, and reinstall from the final public GitHub URL.
- [ ] Enable on a second Omarchy Quattro user or machine.
- [ ] Select videos with `fit`, `fill`, sound off, and sound on.
- [ ] Test one monitor and a multi-monitor setup.
- [ ] Confirm pause, resume, restart, shell restart, disable, and rollback.
- [ ] Select both a theme image and a video from `Super+Ctrl+Space`.
- [ ] Change themes after selecting a video and confirm that the new theme's
  default image replaces it.
- [ ] Review marketplace automated validation and security-baseline results.
