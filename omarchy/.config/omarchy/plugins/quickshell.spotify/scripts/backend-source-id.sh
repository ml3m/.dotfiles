#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

source_root=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
source_files=(
  backend/Cargo.toml
  backend/Cargo.lock
  rust-toolchain.toml
)

for source_file in "$source_root"/backend/src/*.rs; do
  [[ -f $source_file ]] || continue
  source_files+=("${source_file#"$source_root/"}")
done

(
  cd "$source_root"
  file_hashes=$(sha256sum -- "${source_files[@]}")
  source_hash=$(printf '%s\n' "$file_hashes" | sha256sum)
  printf '%s\n' "${source_hash%% *}"
)
