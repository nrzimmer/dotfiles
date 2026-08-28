#!/usr/bin/env bash
# Cycling spanned wallpaper for i3.
# Steps through the images in sorted order (one advance per run) and
# stretches the chosen one across BOTH monitors as if they were a single
# screen (--no-xinerama tells feh to ignore per-output geometry). The
# combined desktop here is 3840x1080 (HDMI-0 1920 + DP-0 2560, minus
# overlap), so the 4480x1080 / 5120x1440 ultrawide images line up across
# the seam.
#
# Pool: images directly under ~/Pictures/Wallpapers (non-recursive, so
# subdirs like old/ or generated/ are ignored). Drop your own
# jpg/png/webp files there and they get mixed in.
#
# Missing pool -> solid gray fallback so you never get a blank screen.

WALL_DIR="$HOME/Pictures/Wallpapers"

# Collect all images, sorted, so the cycle order is stable.
mapfile -d '' -t POOL < <(find "$WALL_DIR" -maxdepth 1 -type f \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
    -print0 2>/dev/null | sort -z)

if [ "${#POOL[@]}" -eq 0 ]; then
    xsetroot -solid "#333333"
    exit 0
fi

# Advance from the last shown image to the next one in the cycle.
STATE="${XDG_CACHE_HOME:-$HOME/.cache}/i3-wallpaper-last"
LAST=$(cat "$STATE" 2>/dev/null)

NEXT=0
for i in "${!POOL[@]}"; do
    if [ "${POOL[$i]}" = "$LAST" ]; then
        NEXT=$(( (i + 1) % ${#POOL[@]} ))
        break
    fi
done

PICK="${POOL[$NEXT]}"

mkdir -p "$(dirname "$STATE")"
printf '%s' "$PICK" > "$STATE"

feh --no-fehbg --no-xinerama --bg-fill "$PICK"
