#!/usr/bin/env bash

# add_file: Move a file from $HOME into this repo (preserving its path) and symlink it back.
# Usage: add_file <path-to-file>

resolve_path() {
  local p="$1"
  [[ -z "$p" ]] && return 1
  # Expand ~ and make absolute
  [[ "$p" == ~* ]] && p="${p/#\~/$HOME}"
  [[ "$p" != /* ]] && p="$PWD/$p"
  if command -v realpath >/dev/null 2>&1; then
    realpath -m "$p" 2>/dev/null || echo "$p"
  elif command -v readlink >/dev/null 2>&1; then
    readlink -f "$p" 2>/dev/null || echo "$p"
  else
    echo "$p"
  fi
}

add_file() {
  local input="$1"
  if [[ -z "$input" ]]; then
    echo "Usage: add_file <path-to-file>" >&2
    return 2
  fi

  local abs
  abs=$(resolve_path "$input")

  # Must be a regular file inside $HOME (not $HOME itself)
  if [[ ! -f "$abs" ]]; then
    echo "Error: File not found or not a regular file: $input" >&2
    return 1
  fi
  if [[ "$abs" != "$HOME"/* ]]; then
    echo "Error: File must be inside your home directory ($HOME): $input" >&2
    return 3
  fi

  local rel="${abs#"$HOME/"}"
  if [[ -z "$rel" || "$rel" == "$abs" ]]; then
    echo "Error: Path resolves to HOME, not a file: $input" >&2
    return 1
  fi

  local repo_dir
  repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local dest="$repo_dir/$rel"
  local dest_dir
  dest_dir="$(dirname "$dest")"

  mkdir -p "$dest_dir" || { echo "Error: Failed to create directory: $dest_dir" >&2; return 4; }

  if [[ -e "$dest" ]]; then
    echo "Error: Destination already exists: $dest" >&2
    return 5
  fi

  mv "$abs" "$dest" || { echo "Error: Failed to move file to: $dest" >&2; return 4; }
  if ln -s "$dest" "$abs"; then
    echo "Moved and linked: $abs -> $dest"
  else
    mv "$dest" "$abs" 2>/dev/null
    echo "Error: Failed to create symlink at origin: $abs" >&2
    return 4
  fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  if [[ $# -eq 0 ]]; then
    echo "Usage: add.sh <path-to-file> [more-files...]" >&2
    exit 2
  fi
  status=0
  for arg in "$@"; do
    if ! add_file "$arg"; then
      status=1
    fi
  done
  exit $status
fi

