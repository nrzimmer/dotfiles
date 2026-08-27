#!/usr/bin/env bash
# Random per-monitor wallpaper for i3.
# Picks a random image (independently) for each connected output, in xrandr order.
# Order on this machine: HDMI-0 (left) first, DP-0 (right/primary) second.
#
# Pool: any image under ~/Pictures/Wallpapers, excluding the generated/
# subdir (bundled gradients from ./gen-wallpapers.sh). Drop your own
# jpg/png/webp files there and they get mixed in.
#
# Missing pool -> solid gray fallback so you never get a blank screen.

WALL_DIR="$HOME/Pictures/Wallpapers"

# Collect all images into an array.
mapfile -d '' POOL < <(find "$WALL_DIR" -type f \
    -not -path "$WALL_DIR/generated/*" \
    \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
    -print0 2>/dev/null)

if [ "${#POOL[@]}" -eq 0 ]; then
    xsetroot -solid "#333333"
    exit 0
fi

# Number of connected outputs (so we pass one image per monitor to feh).
NUM_OUT=$(xrandr --query | grep -c " connected")
[ "$NUM_OUT" -lt 1 ] && NUM_OUT=1

# Pick NUM_OUT random images (may repeat if pool is small).
PICKS=()
for ((i = 0; i < NUM_OUT; i++)); do
    PICKS+=("${POOL[RANDOM % ${#POOL[@]}]}")
done

# feh assigns images to outputs in xrandr order.
feh --no-fehbg --bg-fill "${PICKS[@]}"
