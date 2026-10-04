#!/usr/bin/env bash

set -euo pipefail

readonly waypaper_config="${XDG_CONFIG_HOME:-$HOME/.config}/waypaper/config.ini"

fail() {
  local exit_code="$1"
  shift
  printf 'waypaper-video-background: %s\n' "$*" >&2
  exit "$exit_code"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || fail 69 "required command is not installed: $1"
}

ini_value() {
  local wanted="$1"
  awk -v wanted="$wanted" '
    index($0, "=") == 0 { next }
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

require_command awk
require_command mpvpaper
require_command pgrep
[[ -r $waypaper_config ]] || fail 78 "Waypaper config is not readable: $waypaper_config"

backend="$(ini_value backend)"
[[ $backend == "mpvpaper" ]] || fail 78 "Waypaper backend must be mpvpaper (found: ${backend:-unset})"

wallpaper="$(expand_home_path "$(ini_value wallpaper)")"
[[ -n $wallpaper ]] || fail 78 "Waypaper has no selected wallpaper"
[[ -f $wallpaper ]] || fail 78 "selected wallpaper does not exist: $wallpaper"

monitor="$(ini_value monitors)"
monitor="${monitor:-All}"
[[ $monitor =~ ^[A-Za-z0-9_.-]+$ ]] || fail 78 "unsupported monitor name: $monitor"

fill="$(ini_value fill)"
fill="${fill,,}"
case "$fill" in
  fill) fill_option="panscan=1.0" ;;
  fit) fill_option="panscan=0.0" ;;
  stretch) fill_option="--keepaspect=no" ;;
  center | tile | "") fill_option="" ;;
  *) fail 78 "unsupported Waypaper fill mode: $fill" ;;
esac

color="$(ini_value color)"
color="${color:-#000000}"
sound="$(ini_value mpvpaper_sound)"
sound="${sound,,}"
base_options="$(ini_value mpvpaper_options)"

mpv_options=()
[[ -n $base_options ]] && mpv_options+=("$base_options")
mpv_options+=("loop" "terminal=no")
[[ -n $fill_option ]] && mpv_options+=("$fill_option")
if [[ $sound != "true" && $sound != "yes" && $sound != "1" ]]; then
  mpv_options+=("--mute=yes")
fi
mpv_options+=("--background-color='$color'")

# Waypaper expects this socket path when its backend is mpvpaper.
socket_path="/tmp/mpv-socket-$monitor"
mpv_options=("input-ipc-server=$socket_path" "${mpv_options[@]}")
forwarded_options="${mpv_options[*]}"
output="$monitor"
[[ $monitor == "All" ]] && output="*"

if [[ ${1:-} == "--check" ]]; then
  printf 'backend=%s\nmonitor=%s\nwallpaper=%s\noptions=%s\n' \
    "$backend" "$monitor" "$wallpaper" "$forwarded_options"
  exit 0
fi

# Retire only an mpvpaper instance that owns the exact Waypaper socket this
# plugin is about to reuse. Read argv through procfs so the socket is compared
# literally rather than interpreted as a regular expression. Other monitors
# and unrelated mpvpaper sessions are left alone.
mapfile -t candidate_pids < <(pgrep -x mpvpaper || true)
managed_pids=()
for candidate_pid in "${candidate_pids[@]}"; do
  [[ -r /proc/$candidate_pid/cmdline ]] || continue
  while IFS= read -r -d '' candidate_arg; do
    if [[ $candidate_arg == *"input-ipc-server=$socket_path"* ]]; then
      managed_pids+=("$candidate_pid")
      break
    fi
  done < "/proc/$candidate_pid/cmdline"
done

if (( ${#managed_pids[@]} > 0 )); then
  kill -TERM "${managed_pids[@]}" 2>/dev/null || true
  for (( attempt = 0; attempt < 20; attempt++ )); do
    remaining=0
    for managed_pid in "${managed_pids[@]}"; do
      if kill -0 "$managed_pid" 2>/dev/null; then remaining=1; fi
    done
    (( remaining == 0 )) && break
    sleep 0.1
  done
  for managed_pid in "${managed_pids[@]}"; do
    kill -0 "$managed_pid" 2>/dev/null && \
      fail 75 "existing mpvpaper process did not stop: $managed_pid"
  done
fi

rm -f -- "$socket_path"
exec mpvpaper -o "$forwarded_options" "$output" "$wallpaper"
