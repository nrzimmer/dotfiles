#!/usr/bin/env bash
# Show dismissed dunst notifications in a rofi menu; selecting one re-pops it.
# dunst keeps the last `history_length` notifications (lost on dunst restart).
set -euo pipefail

hist="$(dunstctl history)"
n="$(jq '.data[0] | length' <<<"$hist")"

if [ "$n" -eq 0 ]; then
  notify-send "Dunst history" "No dismissed notifications"
  exit 0
fi

# Parallel arrays: ids[i] corresponds to the i-th rofi row (newest first).
mapfile -t ids < <(jq -r '.data[0][].id.data' <<<"$hist")

labels="$(jq -r '
  .data[0][]
  | (.summary.data) as $s
  | (.body.data | gsub("\n"; " ")) as $b
  | (.appname.data) as $a
  | if ($b | length) > 0 then "[\($a)] \($s) — \($b)" else "[\($a)] \($s)" end
' <<<"$hist")"

idx="$(printf '%s\n' "$labels" | rofi -dmenu -i -p "Dismissed" -format i \
  -me-select-entry '' -me-accept-entry 'MousePrimary')"
[ -z "${idx:-}" ] && exit 0

dunstctl history-pop "${ids[$idx]}"
