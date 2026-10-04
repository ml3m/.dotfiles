#!/usr/bin/env bash

set -euo pipefail

readonly repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly omarchy_path="${OMARCHY_PATH:-/usr/share/omarchy}"

command -v omarchy >/dev/null 2>&1 || {
  printf 'validate: Omarchy is required\n' >&2
  exit 69
}
command -v qmllint >/dev/null 2>&1 || {
  printf 'validate: qmllint is required\n' >&2
  exit 69
}

omarchy plugin validate "$repo_dir"
qmllint -I "$omarchy_path/shell" "$repo_dir/Service.qml"
bash -n "$repo_dir/start-mpvpaper.sh"
bash -n "$repo_dir/control.sh"
bash -n "$repo_dir/background-selector.sh"
bash -n "$repo_dir/selector-integration.sh"
bash -n "$repo_dir/waypaper-video-background-theme-sync"

printf 'Validation passed for %s\n' "$repo_dir"
