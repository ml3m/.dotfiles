#!/usr/bin/env bash

set -euo pipefail

readonly waypaper_config="${XDG_CONFIG_HOME:-$HOME/.config}/waypaper/config.ini"

fail() {
  local exit_code="$1"
  shift
  printf 'waypaper-video-background: %s\n' "$*" >&2
  exit "$exit_code"
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

command -v awk >/dev/null 2>&1 || fail 69 "required command is not installed: awk"
command -v socat >/dev/null 2>&1 || fail 69 "required command is not installed: socat"
[[ -r $waypaper_config ]] || fail 78 "Waypaper config is not readable: $waypaper_config"

action="${1:-}"
monitor="$(ini_value monitors)"
monitor="${monitor:-All}"
[[ $monitor =~ ^[A-Za-z0-9_.-]+$ ]] || fail 78 "unsupported monitor name: $monitor"

socket_path="/tmp/mpv-socket-$monitor"
[[ -S $socket_path ]] || fail 69 "mpvpaper socket is unavailable: $socket_path"

case "$action" in
  pause) mpv_command="set pause yes" ;;
  resume) mpv_command="set pause no" ;;
  toggle) mpv_command="cycle pause" ;;
  *) fail 64 "unsupported control action: ${action:-unset}" ;;
esac

printf '%s\n' "$mpv_command" | socat -T 2 - "UNIX-CONNECT:$socket_path" >/dev/null
