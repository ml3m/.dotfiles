# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.3.1] - 2026-08-16

### Changed

- Simplify the `Add` tile to a pure black background and white plus sign,
  without a decorative border, gradient, or glow.

## [1.3.0] - 2026-08-16

### Added

- Append an `Add` tile to the mixed background selector. Activating it creates
  and opens the current theme's persistent user background directory in
  Nautilus.

## [1.2.1] - 2026-08-16

### Fixed

- Keep building selector sources when the active theme has no optional
  `~/.config/omarchy/backgrounds/<theme>` directory. Previously the selector
  exited early for such themes and appeared to work only with themes that had
  user-specific background extras.

## [1.2.0] - 2026-08-16

### Added

- Synchronize each Omarchy theme change to its selected default image through
  Waypaper, replacing any video selected under the previous theme.
- Install a direct, reversible `Super+Ctrl+Space` Hyprland override so the
  media selector no longer depends on the Omarchy menu route.

### Changed

- The explicit selector integration now manages the menu action, shortcut,
  and `theme-set` hook together, with backups and symmetric removal.

## [1.1.1] - 2026-08-16

### Fixed

- Preserve the native `background` and `wallpaper` route aliases in the
  Omarchy menu override so `Super+Ctrl+Space` opens the media selector instead
  of falling back to the root menu.
- Upgrade an existing managed selector block when the integration installer is
  run again.

## [1.1.0] - 2026-08-16

### Added

- Optional, reversible integration with Omarchy's `Super+Ctrl+Space`
  background selector.
- Mixed theme-image and Waypaper-video discovery with cached filmstrip video
  thumbnails.
- Persistent media selection through Waypaper while keeping still-image lock
  backgrounds synchronized with Omarchy.

## [1.0.1] - 2026-08-16

### Changed

- Shortened the public display name from `Waypaper Video Background` to
  `Waypaper Video` while keeping the repository, plugin ID, and IPC target
  stable.

## [1.0.0] - 2026-08-16

### Added

- Omarchy Quattro service supervision for Waypaper's mpvpaper backend.
- Capped exponential restart backoff after unexpected renderer failures.
- IPC commands for status, lifecycle, pause/resume, and opening Waypaper.
- Configuration validation that does not start the renderer.
- English and French installation, rollback, security, and troubleshooting
  documentation.
