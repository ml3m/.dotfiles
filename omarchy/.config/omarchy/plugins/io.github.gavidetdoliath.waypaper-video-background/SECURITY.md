# Security policy

## Supported versions

Only the latest release on the default branch is supported.

## Reporting a vulnerability

Do not open a public issue for a suspected vulnerability. Use GitHub's private
security advisory form for this repository after it is published.

Include the affected version, impact, reproduction steps, and any suggested
mitigation. Please avoid including personal configuration, credentials, or
private video paths.

## Trust boundary

Omarchy plugins run unsandboxed with the current user's permissions. This
plugin reads Waypaper configuration, starts and controls mpvpaper, and removes
only the Waypaper IPC socket selected for the configured monitor. It does not
request elevated privileges or download and execute remote code.

The optional selector integration runs only when explicitly requested. It
backs up the user-owned Omarchy menu and Hyprland bindings before adding or
removing marked overrides. It also installs a uniquely named `theme-set` hook,
which it removes only when the file still carries the plugin's marker.
Selecting a media item, or changing the Omarchy theme, asks Waypaper to persist
the resulting explicit background and stores generated video thumbnails only
in the user's cache. Activating the selector's `Add` tile creates only the
current theme's user-owned background directory under
`~/.config/omarchy/backgrounds/` and opens it in Nautilus; the plugin does not
copy, move, rename, or delete media in that directory.
