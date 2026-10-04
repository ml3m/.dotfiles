#!/usr/bin/env bash
set -euo pipefail

source_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

# Plugin installs intentionally do not run hooks. Prefer the verified or
# source-built plugin backend, and retain Arch spotifyd as a no-build fallback.
set +e
"$source_root/scripts/setup.sh"
setup_status=$?
set -e
if (( setup_status == 0 )); then
  exit 0
fi
if (( setup_status != 30 )); then
  exit 22
fi

if ! command -v spotifyd >/dev/null 2>&1; then
  command -v pkexec >/dev/null 2>&1 || exit 20
  if ! pkexec /usr/bin/pacman -S --needed --noconfirm spotifyd; then
    exit 21
  fi
fi

if ! "$source_root/scripts/setup.sh" --skip-backend-build; then
  exit 22
fi
