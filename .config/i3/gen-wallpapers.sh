#!/usr/bin/env bash
# Generate a pool of simple gradient wallpapers with ImageMagick.
# Re-run any time to regenerate. Output goes to ~/Pictures/Wallpapers/generated.
set -e

OUT="$HOME/Pictures/Wallpapers/generated"
mkdir -p "$OUT"
SIZE="2560x1080"   # widest monitor; feh --bg-fill crops to fit the narrower one

# name : top-color : bottom-color  (vertical gradients, soft and minimal)
PALETTE=(
  "dusk:#2b5876:#4e4376"
  "ocean:#1a2980:#26d0ce"
  "sunset:#f857a6:#ff5858"
  "mint:#43cea2:#185a9d"
  "peach:#ffb88c:#de6262"
  "slate:#304352:#d7d2cc"
  "grape:#41295a:#2f0743"
  "sky:#2980b9:#6dd5fa"
  "ember:#ff512f:#dd2476"
  "forest:#134e5e:#71b280"
)

for entry in "${PALETTE[@]}"; do
  IFS=':' read -r name top bottom <<< "$entry"
  magick -size "$SIZE" "gradient:${top}-${bottom}" "$OUT/${name}.png"
done

echo "Generated ${#PALETTE[@]} wallpapers in $OUT"
