#!/usr/bin/env bash
# Triggered by systemd path unit when Omarchy's current/background symlink changes.
set -euo pipefail
exec </dev/null

bg=$(readlink -f "${XDG_STATE_HOME:-$HOME/.local/state}/omarchy/current/background" 2>/dev/null || true)
[[ -f ${bg:-} ]] || exit 0

log_dir="${XDG_CACHE_HOME:-$HOME/.cache}/omarchy"
mkdir -p "$log_dir"

(
  flock 9 || exit 0
  updater="$HOME/.config/scripts/matugen-update.sh"
  if [[ -x $updater ]]; then
    "$updater" "$bg" >>"$log_dir/matugen.log" 2>&1 \
      || matugen image "$bg" >>"$log_dir/matugen.log" 2>&1
  else
    matugen image "$bg" >>"$log_dir/matugen.log" 2>&1
  fi
) 9>"${XDG_RUNTIME_DIR:-/tmp}/matugen-walls.lock"
