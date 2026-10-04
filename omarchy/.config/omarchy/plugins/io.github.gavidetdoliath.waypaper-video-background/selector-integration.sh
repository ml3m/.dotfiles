#!/usr/bin/env bash

set -euo pipefail

readonly script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
readonly config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly menu_file="$config_home/omarchy/extensions/omarchy-menu.jsonc"
readonly bindings_file="$config_home/hypr/bindings.lua"
readonly hook_source="$script_dir/waypaper-video-background-theme-sync"
readonly hook_file="$HOME/.config/omarchy/hooks/theme-set.d/${hook_source##*/}"
readonly menu_begin="// BEGIN Waypaper Video background selector"
readonly menu_end="// END Waypaper Video background selector"
readonly binding_begin="-- BEGIN Waypaper Video background selector"
readonly binding_end="-- END Waypaper Video background selector"
readonly hook_marker="# Managed by Waypaper Video. Installed into Omarchy's theme-set.d hook."
readonly override_key='"style.background"'

fail() {
  local exit_code="$1"
  shift
  printf 'waypaper-video-integration: %s\n' "$*" >&2
  exit "$exit_code"
}

backup_file() {
  local path="$1"
  local timestamp backup

  timestamp="$(date +%Y%m%d-%H%M%S-%N)"
  backup="$path.bak.waypaper-video.$timestamp"
  cp -p -- "$path" "$backup"
  printf '%s\n' "$backup"
}

refresh_menu() {
  [[ ${WAYPAPER_VIDEO_SKIP_MENU_REFRESH:-0} == "1" ]] && return
  if command -v omarchy >/dev/null 2>&1; then
    omarchy menu refresh >/dev/null 2>&1 || true
  fi
}

reload_hyprland() {
  local errors

  [[ ${WAYPAPER_VIDEO_SKIP_HYPRLAND_RELOAD:-0} == "1" ]] && return
  command -v hyprctl >/dev/null 2>&1 || return
  if ! hyprctl reload >/dev/null 2>&1; then
    printf 'Warning: Hyprland could not be reloaded; the shortcut will apply on the next reload.\n' >&2
    return
  fi
  errors="$(hyprctl configerrors 2>/dev/null || true)"
  [[ -z $errors ]] || printf 'Warning: Hyprland reports configuration errors:\n%s\n' "$errors" >&2
}

extract_block() {
  local path="$1"
  local begin="$2"
  local end="$3"

  awk -v begin="$begin" -v end="$end" '
    index($0, begin) { capture = 1 }
    capture { print }
    capture && index($0, end) { exit }
  ' "$path"
}

replace_block() {
  local path="$1"
  local begin="$2"
  local end="$3"
  local block="$4"
  local temporary

  temporary="$(mktemp "$path.tmp.XXXXXX")"
  if ! awk -v begin="$begin" -v end="$end" -v block="$block" '
    index($0, begin) {
      if (!replaced) print block
      replaced = 1
      replacing = 1
      next
    }
    replacing && index($0, end) { replacing = 0; next }
    !replacing { print }
    END { if (!replaced) exit 1 }
  ' "$path" >"$temporary"; then
    rm -f -- "$temporary"
    return 1
  fi
  chmod --reference="$path" "$temporary"
  mv -f -- "$temporary" "$path"
}

remove_block() {
  local path="$1"
  local begin="$2"
  local end="$3"
  local temporary

  temporary="$(mktemp "$path.tmp.XXXXXX")"
  awk -v begin="$begin" -v end="$end" '
    index($0, begin) { removing = 1; next }
    index($0, end) { removing = 0; next }
    !removing { print }
  ' "$path" >"$temporary"
  chmod --reference="$path" "$temporary"
  mv -f -- "$temporary" "$path"
}

install_menu() {
  local menu_dir backup temporary block current_block

  menu_dir="${menu_file%/*}"
  mkdir -p -- "$menu_dir"
  if [[ ! -e $menu_file ]]; then
    printf '{\n}\n' >"$menu_file"
  fi
  [[ -f $menu_file && -r $menu_file && -w $menu_file ]] || \
    fail 73 "menu extension is not a writable file: $menu_file"

  block='  // BEGIN Waypaper Video background selector
  "style.background": {"icon":"","label":"Background","aliases":["background","wallpaper"],"action":"$HOME/.config/omarchy/plugins/io.github.gavidetdoliath.waypaper-video-background/background-selector.sh"},
  // END Waypaper Video background selector'

  if grep -Fq -- "$menu_begin" "$menu_file"; then
    grep -Fq -- "$menu_end" "$menu_file" || \
      fail 65 "managed menu block is missing its end marker"
    current_block="$(extract_block "$menu_file" "$menu_begin" "$menu_end")"
    if [[ $current_block == "$block" ]]; then
      printf 'Omarchy menu action is already integrated.\n'
      return
    fi

    backup="$(backup_file "$menu_file")"
    replace_block "$menu_file" "$menu_begin" "$menu_end" "$block" || \
      fail 65 "could not update the managed menu block"
    printf 'Updated the Omarchy menu action.\nBackup: %s\n' "$backup"
    return
  fi
  if grep -Eq "^[[:space:]]*$override_key[[:space:]]*:" "$menu_file"; then
    fail 65 "style.background already has a user override; refusing to replace it"
  fi

  backup="$(backup_file "$menu_file")"
  temporary="$(mktemp "$menu_file.tmp.XXXXXX")"
  if ! awk -v block="$block" '
    { print }
    !inserted && /^[[:space:]]*\{[[:space:]]*$/ { print block; inserted = 1 }
    END { if (!inserted) exit 1 }
  ' "$menu_file" >"$temporary"; then
    rm -f -- "$temporary"
    fail 65 "menu extension is not a top-level JSONC object"
  fi
  chmod --reference="$menu_file" "$temporary"
  mv -f -- "$temporary" "$menu_file"
  printf 'Integrated the Omarchy menu action.\nBackup: %s\n' "$backup"
}

install_shortcut() {
  local bindings_dir backup block current_block temporary

  bindings_dir="${bindings_file%/*}"
  mkdir -p -- "$bindings_dir"
  [[ -e $bindings_file ]] || : >"$bindings_file"
  [[ -f $bindings_file && -r $bindings_file && -w $bindings_file ]] || \
    fail 73 "Hyprland bindings are not a writable file: $bindings_file"

  block='-- BEGIN Waypaper Video background selector
-- Replaces the stock Omarchy Background switcher binding with the direct selector.
hl.unbind("SUPER + CTRL + SPACE")
o.bind("SUPER + CTRL + SPACE", "Waypaper Video backgrounds", "$HOME/.config/omarchy/plugins/io.github.gavidetdoliath.waypaper-video-background/background-selector.sh")
-- END Waypaper Video background selector'

  if grep -Fq -- "$binding_begin" "$bindings_file"; then
    grep -Fq -- "$binding_end" "$bindings_file" || \
      fail 65 "managed shortcut block is missing its end marker"
    current_block="$(extract_block "$bindings_file" "$binding_begin" "$binding_end")"
    if [[ $current_block == "$block" ]]; then
      printf 'Super+Ctrl+Space shortcut is already integrated.\n'
      return
    fi

    backup="$(backup_file "$bindings_file")"
    replace_block "$bindings_file" "$binding_begin" "$binding_end" "$block" || \
      fail 65 "could not update the managed shortcut block"
    printf 'Updated the Super+Ctrl+Space shortcut.\nBackup: %s\n' "$backup"
    return
  fi
  if grep -Eiq '^[[:space:]]*(hl\.unbind|hl\.bind|o\.bind).*SUPER[[:space:]]*\+[[:space:]]*CTRL[[:space:]]*\+[[:space:]]*SPACE' "$bindings_file"; then
    fail 65 "Super+Ctrl+Space already has a user override; refusing to replace it"
  fi

  backup="$(backup_file "$bindings_file")"
  temporary="$(mktemp "$bindings_file.tmp.XXXXXX")"
  awk -v block="$block" '
    { print }
    END { print block }
  ' "$bindings_file" >"$temporary"
  chmod --reference="$bindings_file" "$temporary"
  mv -f -- "$temporary" "$bindings_file"
  printf 'Integrated Super+Ctrl+Space directly with Waypaper Video.\nBackup: %s\n' "$backup"
}

install_theme_hook() {
  local backup

  [[ -x $hook_source ]] || fail 69 "theme hook source is missing or not executable: $hook_source"
  if [[ -e $hook_file ]]; then
    [[ -f $hook_file ]] || fail 73 "theme hook target is not a file: $hook_file"
    grep -Fq -- "$hook_marker" "$hook_file" || \
      fail 65 "theme hook path is already owned by another customization: $hook_file"
    if cmp -s -- "$hook_source" "$hook_file"; then
      printf 'Theme background synchronization hook is already integrated.\n'
      return
    fi
    backup="$(backup_file "$hook_file")"
  else
    backup=""
  fi

  command -v omarchy >/dev/null 2>&1 || fail 69 "omarchy command is not installed"
  omarchy hook install theme-set "$hook_source" >/dev/null
  printf 'Integrated theme background synchronization.\n'
  [[ -z $backup ]] || printf 'Backup: %s\n' "$backup"
}

remove_menu() {
  local backup

  if [[ ! -f $menu_file ]] || ! grep -Fq -- "$menu_begin" "$menu_file"; then
    printf 'Omarchy menu action is not integrated.\n'
    return
  fi
  grep -Fq -- "$menu_end" "$menu_file" || fail 65 "managed menu block is missing its end marker"
  backup="$(backup_file "$menu_file")"
  remove_block "$menu_file" "$menu_begin" "$menu_end"
  printf 'Restored the stock Omarchy menu action.\nBackup: %s\n' "$backup"
}

remove_shortcut() {
  local backup

  if [[ ! -f $bindings_file ]] || ! grep -Fq -- "$binding_begin" "$bindings_file"; then
    printf 'Super+Ctrl+Space shortcut is not integrated.\n'
    return
  fi
  grep -Fq -- "$binding_end" "$bindings_file" || fail 65 "managed shortcut block is missing its end marker"
  backup="$(backup_file "$bindings_file")"
  remove_block "$bindings_file" "$binding_begin" "$binding_end"
  printf 'Restored the stock Omarchy Super+Ctrl+Space binding.\nBackup: %s\n' "$backup"
}

remove_theme_hook() {
  local backup

  if [[ ! -e $hook_file ]]; then
    printf 'Theme background synchronization hook is not integrated.\n'
    return
  fi
  [[ -f $hook_file ]] || fail 73 "theme hook target is not a file: $hook_file"
  grep -Fq -- "$hook_marker" "$hook_file" || \
    fail 65 "refusing to remove a theme hook not managed by Waypaper Video"
  backup="$(backup_file "$hook_file")"
  rm -f -- "$hook_file"
  printf 'Removed theme background synchronization.\nBackup: %s\n' "$backup"
}

install_all() {
  install_menu
  install_shortcut
  install_theme_hook
  refresh_menu
  reload_hyprland
}

remove_all() {
  remove_theme_hook
  remove_shortcut
  remove_menu
  refresh_menu
  reload_hyprland
}

show_status() {
  local menu_status="no" shortcut_status="no" hook_status="no"

  [[ -f $menu_file ]] && grep -Fq -- "$menu_begin" "$menu_file" && menu_status="yes"
  [[ -f $bindings_file ]] && grep -Fq -- "$binding_begin" "$bindings_file" && shortcut_status="yes"
  [[ -f $hook_file ]] && grep -Fq -- "$hook_marker" "$hook_file" && hook_status="yes"

  if [[ $menu_status == "yes" && $shortcut_status == "yes" && $hook_status == "yes" ]]; then
    printf 'integrated\n'
  elif [[ $menu_status == "no" && $shortcut_status == "no" && $hook_status == "no" ]]; then
    printf 'not-integrated\n'
  else
    printf 'partial menu=%s shortcut=%s theme-sync=%s\n' \
      "$menu_status" "$shortcut_status" "$hook_status"
  fi
}

case "${1:-status}" in
  install) install_all ;;
  remove) remove_all ;;
  status) show_status ;;
  *) fail 64 "usage: ${0##*/} [install|remove|status]" ;;
esac
