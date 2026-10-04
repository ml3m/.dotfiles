# Waypaper Video for Omarchy

[Français](README.fr.md)

An Omarchy Quattro service plugin that supervises the `mpvpaper` video
wallpaper configured through Waypaper. Day-to-day media selection stays in
Omarchy's native background selector, while the plugin gives the renderer a
reliable lifecycle inside `omarchy-shell`.

https://github.com/user-attachments/assets/e52bdc97-a4bf-4012-ac9b-3fb3308e1577

## Features

- Uses Waypaper as the configuration and persistence layer behind Omarchy's
  day-to-day background picker.
- Adds both theme images and Waypaper videos to Omarchy's native background
  selector opened with `Super+Ctrl+Space`.
- Appends an **Add** tile—the recommended way to add images and videos—which
  opens the current theme's personal background folder in the same file manager
  as `Super+Shift+F`.
- Replaces the previous theme's video with the new theme's selected default
  image whenever the Omarchy theme changes.
- Runs `mpvpaper` in the foreground so Omarchy Shell owns its lifecycle.
- Restarts unexpected crashes with capped exponential backoff.
- Supports start, stop, restart, pause, resume, and toggle through IPC.
- Stops the managed renderer when the plugin is disabled or the shell exits.
- Never edits packaged files under `/usr/share/omarchy`.

## Compatibility and requirements

Tested with:

- Omarchy `4.0.0` (Quattro), plugin manifest schema `1`
- Waypaper `2.8`
- mpvpaper `1.9`

Runtime commands and their Arch packages:

| Command | Package | Purpose |
| --- | --- | --- |
| `waypaper` | `waypaper` (AUR) | Graphical picker and configuration |
| `mpvpaper` | `mpvpaper` (AUR) | Video renderer |
| `socat` | `socat` | Pause/resume IPC controls |
| `ffmpegthumbnailer` | `ffmpegthumbnailer` | Video previews in the selector |
| `awk` | `gawk` | Read Waypaper's INI file |
| `pgrep` | `procps-ng` | Retire the renderer using the selected socket |
| `uwsm-app` | `uwsm` | Open Waypaper in the current desktop session |
| `nautilus` | `nautilus` | Open the current theme's personal background folder |
| `setsid` | `util-linux` | Launch that file-manager window independently |

Omarchy normally already provides `gawk`, `procps-ng`, `uwsm`, `nautilus`, and
`util-linux`. Install the remaining packages with Omarchy's package helpers:

```sh
omarchy pkg aur add mpvpaper waypaper
omarchy pkg add socat ffmpegthumbnailer
```

## Install

The plugin executes unsandboxed with your user permissions. Review the source
before enabling it.

```sh
omarchy plugin add \
  https://github.com/GavidetDoliath/omarchy-waypaper-video-background.git
```

When the interactive command asks whether to enable the plugin immediately,
answer **No**. The plugin remains disabled, which leaves the current static
background untouched while Waypaper is configured. In a non-interactive
shell, the plugin remains disabled unless `--enable` is passed explicitly.

## One-time Waypaper setup

This initial setup is currently required. The plugin reads Waypaper's existing
configuration and deliberately does not rewrite it during installation, so it
does not select the `mpvpaper` backend automatically.

1. Open Waypaper.
2. Select `mpvpaper` as the backend.
3. Select the folder containing your videos.
4. Choose a video and the desired fill mode.
5. Keep sound disabled unless wallpaper audio is intentional.

Useful Waypaper settings include:

```ini
backend = mpvpaper
mpvpaper_sound = False
mpvpaper_options = hwdec=auto loop-file=inf
```

Validate the resolved configuration without starting a renderer:

```sh
~/.config/omarchy/plugins/io.github.gavidetdoliath.waypaper-video-background/start-mpvpaper.sh --check
```

After the check succeeds, replace Omarchy's static background service:

```sh
omarchy plugin disable omarchy.background
omarchy plugin enable io.github.gavidetdoliath.waypaper-video-background
```

Install the mixed image/video selector integration (recommended):

```sh
~/.config/omarchy/plugins/io.github.gavidetdoliath.waypaper-video-background/selector-integration.sh install
```

This explicit setup step backs up and installs three user-owned integrations:
the `style.background` menu action, a direct `Super+Ctrl+Space` Hyprland
binding, and an Omarchy `theme-set` hook. It never edits packaged Omarchy
files. The selector then shows images from the current theme and media from the
folders configured in Waypaper. Video entries use generated filmstrip
thumbnails. Selecting any item updates Waypaper and the supervised mpvpaper
process. Selecting a still image also keeps the Omarchy lock-screen background
in sync. Changing themes persists and displays the image selected by the new
theme, replacing any video from the previous one. The final **Add** tile creates
and opens `~/.config/omarchy/backgrounds/<current-theme>/`; media copied there
appears in that theme's selector the next time it is opened.

The recommended everyday workflow is to open the selector with
`Super+Ctrl+Space`, choose **Add**, copy images or videos into the folder that
opens, then reopen the selector and choose the new media. Open Waypaper directly
only to change renderer settings or add other media folders:

```sh
omarchy-shell waypaper-video-background open
```

Waypaper sends the selection to the managed mpvpaper process through its IPC
socket, so the Omarchy service does not need to be restarted for each video.

Inspect the media sources without opening the selector:

```sh
~/.config/omarchy/plugins/io.github.gavidetdoliath.waypaper-video-background/background-selector.sh --check
```

## Controls

```sh
omarchy-shell waypaper-video-background status
omarchy-shell waypaper-video-background start
omarchy-shell waypaper-video-background stop
omarchy-shell waypaper-video-background restart
omarchy-shell waypaper-video-background pause
omarchy-shell waypaper-video-background resume
omarchy-shell waypaper-video-background toggle
omarchy-shell waypaper-video-background open
```

`status` returns JSON containing the process state, PID, restart attempts, last
exit code, and last error message.

## Update

```sh
omarchy plugin update io.github.gavidetdoliath.waypaper-video-background
```

Omarchy shows the incoming Git diff and updates by fast-forward.

## Disable, roll back, and remove

Return to Omarchy's static background before removing the plugin:

```sh
~/.config/omarchy/plugins/io.github.gavidetdoliath.waypaper-video-background/selector-integration.sh remove
omarchy plugin disable io.github.gavidetdoliath.waypaper-video-background
omarchy plugin enable omarchy.background
omarchy plugin remove io.github.gavidetdoliath.waypaper-video-background
```

Removal unloads the service and deletes only the Git checkout. It does not
delete Waypaper's configuration, your video folder, or the installed packages.

## Behavior and security boundaries

- The plugin reads `~/.config/waypaper/config.ini` to resolve its settings.
- A media choice is explicit consent for Waypaper itself to persist the
  selected wallpaper in its configuration.
- The optional selector integration changes only the user-owned Omarchy menu
  extension and Hyprland bindings, creates timestamped backups first, and adds
  one marked `theme-set` hook. Its matching `remove` command reverses all three.
- Changing themes authorizes Waypaper to persist the new theme's default image
  so it replaces a video selected under the previous theme.
- Generated video thumbnails live under
  `~/.cache/omarchy/waypaper-video-selector/`.
- Activating **Add** explicitly authorizes creation of the current theme's
  personal background directory and opens it in Nautilus. The plugin does not
  copy, move, rename, or delete media placed there.
- It creates the Waypaper-compatible socket `/tmp/mpv-socket-<monitor>`.
- Before starting, it terminates only an existing user-owned `mpvpaper`
  process whose command line uses that exact socket.
- It launches no downloader, installer, system service, `sudo`, or `pkexec`.
- Video wallpapers continuously use rendering resources. Pause or stop the
  renderer on battery when needed.
- The current Waypaper `monitors` value selects either one output or `All`.

## Troubleshooting

### Configuration and runtime status

Check the effective Waypaper settings:

```sh
~/.config/omarchy/plugins/io.github.gavidetdoliath.waypaper-video-background/start-mpvpaper.sh --check
```

Inspect the managed process:

```sh
omarchy-shell waypaper-video-background status | jq
```

Confirm discovery and enablement:

```sh
omarchy plugin list --json \
  | jq '.[] | select(.id == "io.github.gavidetdoliath.waypaper-video-background")'
```

Inspect recent shell errors:

```sh
qs log -p "$OMARCHY_PATH/shell" --tail 100
```

Configuration or dependency errors stop automatic retries. Correct the issue,
then run `omarchy-shell waypaper-video-background start`.

## Development

Validate the repository on Omarchy Quattro:

```sh
./validate.sh
```

The validation script checks the official Omarchy manifest contract, QML, and
shell syntax without starting the wallpaper. See [TESTING.md](TESTING.md) for
the completed local verification and the remaining public-release matrix.

## License

[MIT](LICENSE)
