#!/usr/bin/env bash

set -euo pipefail

readonly script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
readonly cache_home="${XDG_CACHE_HOME:-$HOME/.cache}"
readonly waypaper_config="$config_home/waypaper/config.ini"
readonly selector_cache="$cache_home/omarchy/waypaper-video-selector"
readonly add_thumbnail="$script_dir/assets/add-background-minimal.svg"

fail() {
  local exit_code="$1"
  shift
  printf 'waypaper-video-selector: %s\n' "$*" >&2
  exit "$exit_code"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail 69 "required command is not installed: $1"
}

ini_value() {
  local wanted="$1"
  awk -v wanted="$wanted" '
    /^\[Settings\][[:space:]]*$/ { in_settings = 1; next }
    /^\[/ { in_settings = 0 }
    !in_settings || index($0, "=") == 0 { next }
    {
      separator = index($0, "=")
      key = substr($0, 1, separator - 1)
      value = substr($0, separator + 1)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      if (key == wanted) { print value; exit }
    }
  ' "$waypaper_config"
}

ini_list() {
  local wanted="$1"
  awk -v wanted="$wanted" '
    /^\[Settings\][[:space:]]*$/ { in_settings = 1; collecting = 0; next }
    /^\[/ { in_settings = 0; collecting = 0 }
    !in_settings { next }
    collecting && /^[[:space:]]+/ {
      value = $0
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      if (value != "") print value
      next
    }
    index($0, "=") == 0 { collecting = 0; next }
    {
      separator = index($0, "=")
      key = substr($0, 1, separator - 1)
      value = substr($0, separator + 1)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", key)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      collecting = (key == wanted)
      if (collecting && value != "") print value
    }
  ' "$waypaper_config"
}

expand_home_path() {
  local path="$1"
  if [[ $path == "~/"* ]]; then
    printf '%s/%s\n' "$HOME" "${path:2}"
  elif [[ $path == "~" ]]; then
    printf '%s\n' "$HOME"
  else
    printf '%s\n' "$path"
  fi
}

is_image() {
  local path="${1,,}"
  case "$path" in
    *.jpg | *.jpeg | *.png | *.gif | *.bmp | *.webp | *.avif) return 0 ;;
    *) return 1 ;;
  esac
}

is_video() {
  local path="${1,,}"
  case "$path" in
    *.webm | *.mkv | *.flv | *.vob | *.ogv | *.ogg | *.gifv | *.mov | \
      *.avi | *.wmv | *.mp4 | *.m4p | *.m4v | *.mpg | *.mpeg | *.mpe | \
      *.mpv | *.3gp | *.3g2 | *.mxf | *.roq | *.nsv | *.f4v | *.mod) return 0 ;;
    *) return 1 ;;
  esac
}

thumbnail_for_video() {
  local video="$1"
  local signature hash thumbnail temporary

  signature="$(stat -Lc '%s:%Y' "$video")" || return 1
  hash="$(printf '%s\t%s' "$video" "$signature" | md5sum | cut -d ' ' -f 1)"
  thumbnail="$selector_cache/$hash.jpg"

  if [[ ! -f $thumbnail ]]; then
    temporary="$thumbnail.$$.jpg"
    if ffmpegthumbnailer -i "$video" -o "$temporary" -s 1024 -t 10% -q 8 -f \
      >/dev/null 2>&1; then
      mv -f -- "$temporary" "$thumbnail"
    else
      rm -f -- "$temporary"
      printf 'waypaper-video-selector: could not thumbnail %s\n' "$video" >&2
      return 1
    fi
  fi

  printf '%s\n' "$thumbnail"
}

add_media_dir() {
  local candidate="$1"
  [[ -n $candidate ]] || return 0
  candidate="$(expand_home_path "$candidate")"
  [[ -d $candidate ]] || return 0
  candidate="$(realpath -e -- "$candidate")" || return 0
  [[ -n ${seen_dirs[$candidate]:-} ]] && return 0
  seen_dirs[$candidate]=1
  media_dirs+=("$candidate")
}

collect_media_dirs() {
  local folder

  add_media_dir "$state_home/omarchy/current/theme/backgrounds"
  add_media_dir "$theme_media_dir"

  while IFS= read -r folder; do
    add_media_dir "$folder"
  done < <(ini_list folder)
}

collect_media() {
  local generate_thumbnails="$1"
  local directory media canonical thumbnail

  rows=""
  image_count=0
  video_count=0
  media_paths=()

  for directory in "${media_dirs[@]}"; do
    while IFS= read -r -d '' media; do
      if ! is_image "$media" && ! is_video "$media"; then
        continue
      fi

      canonical="$(realpath -e -- "$media")" || continue
      [[ -n ${seen_media[$canonical]:-} ]] && continue
      seen_media[$canonical]=1
      media_paths+=("$canonical")

      if is_video "$canonical"; then
        (( video_count += 1 ))
        [[ $generate_thumbnails == true ]] || continue
        thumbnail="$(thumbnail_for_video "$canonical")" || continue
      else
        (( image_count += 1 ))
        [[ $generate_thumbnails == true ]] || continue
        thumbnail="$canonical"
      fi

      if [[ -z $rows ]]; then
        rows="$canonical"$'\t'"$thumbnail"
      else
        rows+=$'\n'"$canonical"$'\t'"$thumbnail"
      fi
    done < <(find -L "$directory" -maxdepth 1 -type f -print0 2>/dev/null | sort -z)
  done
}

append_add_row() {
  local add_row="$add_selection"$'\t'"$add_thumbnail"

  if [[ -z $rows ]]; then
    rows="$add_row"
  else
    rows+=$'\n'"$add_row"
  fi
}

open_theme_media_dir() {
  require_command nautilus
  require_command setsid
  require_command uwsm-app

  mkdir -p -- "$theme_media_dir"

  # Match Omarchy's Super+Shift+F launcher, with the current theme's persistent
  # user background directory supplied as the initial Nautilus location.
  setsid -f uwsm-app -- nautilus --new-window "$theme_media_dir" \
    >/dev/null 2>&1
}

apply_selection() {
  local selection="$1"
  local monitor

  # Waypaper 2.x forwards the path to its mpvpaper command line. Reject shell
  # metacharacters that could make an otherwise valid filename ambiguous.
  case "$selection" in
    *$'\n'* | *$'\r'* | *$'\t'* | *\'* | *\"*)
      fail 78 "selected media path contains unsupported quotes or control characters"
      ;;
  esac

  monitor="$(ini_value monitors)"
  monitor="${monitor:-All}"
  [[ $monitor =~ ^[A-Za-z0-9_.-]+$ ]] || fail 78 "unsupported monitor name: $monitor"

  waypaper --backend mpvpaper --monitor "$monitor" --wallpaper "$selection" \
    --no-post-command >/dev/null

  # Keep Omarchy's lock screen on the last selected still image. Videos are
  # deliberately not linked because the lock-screen Image item cannot render
  # them.
  if is_image "$selection"; then
    omarchy-theme-bg-set "$selection" >/dev/null 2>&1 || true
  fi

  # If the service had stopped because the previous path was invalid, the new
  # valid Waypaper selection should make it supervised again.
  omarchy-shell waypaper-video-background start >/dev/null 2>&1 || true
}

mode="${1:-open}"
case "$mode" in
  open | --check | --list) ;;
  *) fail 64 "usage: ${0##*/} [--check|--list]" ;;
esac

require_command awk
require_command base64
require_command ffmpegthumbnailer
require_command find
require_command md5sum
require_command omarchy-shell
require_command realpath
require_command stat
require_command waypaper
[[ -r $waypaper_config ]] || fail 78 "Waypaper config is not readable: $waypaper_config"
[[ $(ini_value backend) == "mpvpaper" ]] || fail 78 "Waypaper backend must be mpvpaper"
[[ -r $add_thumbnail ]] || fail 78 "Add tile thumbnail is not readable: $add_thumbnail"

theme_name="$(sed -n '1p' "$state_home/omarchy/current/theme.name" 2>/dev/null || true)"
[[ -n $theme_name ]] || fail 78 "could not resolve the current Omarchy theme"
case "$theme_name" in
  . | .. | */* | *$'\n'* | *$'\r'* | *$'\t'*)
    fail 78 "unsupported current Omarchy theme name: $theme_name"
    ;;
esac
readonly theme_name
readonly theme_media_dir="$config_home/omarchy/backgrounds/$theme_name"
readonly add_selection="$selector_cache/Add"

declare -A seen_dirs=()
declare -A seen_media=()
declare -a media_dirs=()
declare -a media_paths=()
rows=""
image_count=0
video_count=0

collect_media_dirs

if [[ $mode == "--check" ]]; then
  collect_media false
  printf 'directories=%d\nimages=%d\nvideos=%d\nadd_directory=%s\n' \
    "${#media_dirs[@]}" "$image_count" "$video_count" "$theme_media_dir"
  exit 0
fi

mkdir -p -- "$selector_cache"
collect_media true
append_add_row

if [[ $mode == "--list" ]]; then
  printf '%s\n' "$rows"
  exit 0
fi

omarchy-shell waypaper-video-background status >/dev/null 2>&1 || \
  fail 69 "Waypaper Video is not enabled in Omarchy Shell"

selection_file="$(mktemp)"
done_file="$(mktemp)"
rm -f -- "$done_file"
trap 'rm -f -- "$selection_file" "$done_file"' EXIT

current_wallpaper="$(expand_home_path "$(ini_value wallpaper)")"
rows_b64="$(printf '%s' "$rows" | base64 -w 0)"

open_result="$(omarchy-shell image-selector open \
  "" \
  "$rows_b64" \
  "$current_wallpaper" \
  "$selection_file" \
  "$done_file" \
  "true" \
  "true")" || fail 69 "background selector failed to accept request"
[[ $open_result == "ok" ]] || fail 69 "background selector failed to accept request"

while [[ ! -e $done_file ]]; do
  sleep 0.01
done

if [[ -s $selection_file ]]; then
  selection="$(<"$selection_file")"
  if [[ $selection == "$add_selection" ]]; then
    open_theme_media_dir
  else
    [[ -f $selection ]] || fail 78 "selected media no longer exists: $selection"
    apply_selection "$selection"
  fi
fi
