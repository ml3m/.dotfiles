# Marketplace submission

Status: ready for owner approval; not yet submitted.

Prepared for Waypaper Video `v1.3.1` and plugin ID
`io.github.gavidetdoliath.waypaper-video-background`.

The target is the independent community marketplace at
<https://omarchyplugins.com/>, submitted through
`HANCORE-linux/omarchy-plugin-marketplace`.

## Proposed listing

- Repository: `https://github.com/GavidetDoliath/omarchy-waypaper-video-background`
- Category: `Appearance`
- Tags: `media`, `quickshell`, `hyprland`
- Suggested missing tag: `wallpaper`
- Title: `[Plugin]: Waypaper Video`

## Final issue body

```markdown
### Repository URL

https://github.com/GavidetDoliath/omarchy-waypaper-video-background

### Category

Appearance

### Tags

media, quickshell, hyprland

### Suggest a missing tag

wallpaper

### Maintainer notes

Waypaper Video is an Omarchy Quattro service plugin that supervises the
mpvpaper backend configured through Waypaper. It adds current-theme images and
Waypaper videos to Omarchy's background selector, generates cached previews for
videos, and provides lifecycle plus pause/resume controls through Omarchy Shell.

Its optional selector integration is installed only by an explicit
`selector-integration.sh install` command. It creates timestamped backups before
adding marked, reversible user-owned menu, Hyprland shortcut, and `theme-set`
hook entries; it refuses conflicting user overrides. Theme changes replace a
previous theme's video with the new theme's selected image. The selector also
includes an explicit Add tile that creates and opens the current theme's
personal background folder.

External runtime dependencies are Waypaper, mpvpaper, socat, and
ffmpegthumbnailer. The README documents their packages, setup, permissions,
installation, rollback, and removal. The plugin does not download software,
request elevated privileges, install a system service, or edit packaged files
under `/usr/share/omarchy`.

### Submission checklist

- [x] The repository is public and contains installation and removal instructions.
- [x] I have documented the plugin license and any external dependencies.
- [x] I confirm that I own or have permission to submit this plugin and its preview assets.
- [x] The plugin does not overwrite user configuration without explicit consent.
- [x] I understand that approval is for listing and is not a security review.
```

## Submission command

Run only after the owner has reviewed and explicitly approved the title and
complete issue body above:

```sh
gh issue create \
  --repo HANCORE-linux/omarchy-plugin-marketplace \
  --title "[Plugin]: Waypaper Video" \
  --body-file /tmp/omarchy-plugin-submission.md
```

After creation, review the automated compatibility and security-baseline
comments on the existing issue. Fix the repository or edit that issue to retry;
do not open a duplicate submission.
