#!/usr/bin/env bash

# remove_file: Undo what add.sh does.
# Given a path that is currently a symlink in $HOME, verify it points
# into this repository; if so, restore the real file back in place.
# Usage: remove_file <path-to-symlink>

set -euo pipefail

resolve_path() {
  # Expand ~ and make absolute WITHOUT resolving symlinks
  local p="${1-}"
  [[ -z "${p}" ]] && return 1
  # Expand ~
  if [[ "$p" == ~* ]]; then
    p="${p/#\~/$HOME}"
  fi
  # If relative, prepend current working directory (logical, no resolution)
  if [[ "$p" != /* ]]; then
    p="$PWD/$p"
  fi
  # Do not canonicalize or resolve symlinks here; return as-is
  echo "$p"
}

remove_file() {
  local input="${1-}"
  if [[ -z "$input" ]]; then
    echo "Usage: remove_file <path-to-symlink>" >&2
    return 2
  fi

  local abs
  abs=$(resolve_path "$input")

  # Must be a symlink
  if [[ ! -L "$abs" ]]; then
    echo "Error: Not a symlink: $input" >&2
    return 1
  fi

  # Repo directory (same as add.sh)
  local repo_dir
  repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  # Resolve the symlink target to an absolute canonical path
  local target
  if command -v realpath >/dev/null 2>&1; then
    target=$(realpath -m "$abs" 2>/dev/null || true)
  else
    target=$(readlink -f "$abs" 2>/dev/null || true)
  fi

  if [[ -z "${target}" || ! -e "${target}" ]]; then
    echo "Error: Symlink target does not exist or could not be resolved: $abs" >&2
    return 3
  fi
  if [[ ! -f "$target" ]]; then
    echo "Error: Symlink target is not a regular file: $target" >&2
    return 3
  fi
  case "$target" in
    "$repo_dir"/*) ;;
    *)
      echo "Error: Symlink target is not inside this repository: $target" >&2
      return 4
      ;;
  esac

  # Restore: remove the link, then move the file back
  rm "$abs" || { echo "Error: Failed to remove symlink: $abs" >&2; return 6; }
  if mv "$target" "$abs"; then
    # Attempt to remove now-empty directories in the repo where the file used to be
    local parent_dir
    parent_dir="$(dirname "$target")"
    while [[ "$parent_dir" == "$repo_dir"/* && "$parent_dir" != "$repo_dir" ]]; do
      rmdir "$parent_dir" 2>/dev/null || break
      parent_dir="$(dirname "$parent_dir")"
    done
    echo "Restored: $abs"
  else
    # Best-effort: restore the link if move failed
    ln -s "$target" "$abs" 2>/dev/null || true
    echo "Error: Failed to move file back to: $abs" >&2
    return 6
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [[ $# -eq 0 ]]; then
    echo "Usage: remove.sh <path-to-symlink> [more-paths...]" >&2
    exit 2
  fi
  status=0
  for arg in "$@"; do
    if remove_file "$arg"; then
      :
    else
      status=1
    fi
  done
  exit $status
fi
