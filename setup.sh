#!/usr/bin/env bash

# setup.sh: Symlink all files from this repository into the user's home directory,
# preserving their relative paths.
# - Exclude: add.sh, remove.sh, setup.sh, .gitignore (at repo root)
# - Exclude directories: .git, .idea
# - If a destination already exists (file/dir/symlink) and is not the correct
#   symlink, move it aside to a backup with ".original" appended. If that backup
#   exists, append a numeric suffix.
#
# Usage: ./setup.sh

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

is_root_script() {
  local path="$1"
  case "$path" in
    "$repo_dir/add.sh"|"$repo_dir/remove.sh"|"$repo_dir/setup.sh"|"$repo_dir/.gitignore") return 0 ;;
    *) return 1 ;;
  esac
}

backup_path() {
  # Echo a backup path that doesn't exist yet, starting with <path>.original
  local original="$1.original"
  if [[ ! -e "$original" && ! -L "$original" ]]; then
    echo "$original"
    return 0
  fi
  local i=1
  while [[ -e "$original.$i" || -L "$original.$i" ]]; do
    i=$((i+1))
  done
  echo "$original.$i"
}

# Iterate over files, excluding .git and .idea directories
# Using -print0 to safely handle spaces/newlines in filenames
while IFS= read -r -d '' file; do
  # Skip the management scripts at repo root
  if is_root_script "$file"; then
    continue
  fi

  # Compute relative path to repo and corresponding destination under $HOME
  rel="${file#"$repo_dir/"}"
  dest="$HOME/$rel"

  mkdir -p "$(dirname "$dest")"

  # Determine if dest is already the correct symlink
  if [[ -L "$dest" ]]; then
    # Resolve symlink target
    if command -v realpath >/dev/null 2>&1; then
      target=$(realpath -m "$dest" 2>/dev/null || true)
    else
      target=$(readlink -f "$dest" 2>/dev/null || true)
    fi
    if [[ "$target" == "$file" ]]; then
      echo "Already linked: $dest"
      continue
    fi
  fi

  # Backup any existing destination that isn't the correct link
  if [[ -e "$dest" || -L "$dest" ]]; then
    bkp="$(backup_path "$dest")"
    mv "$dest" "$bkp"
    echo "Backed up: $dest -> $bkp"
  fi

  ln -s "$file" "$dest"
  echo "Linked: $dest -> $file"

done < <(find "$repo_dir" \
  \( -name .git -o -name .idea \) -prune -o -type f -print0)
