#!/usr/bin/env bash
# Claude Code statusline.
#
# Single line, only emitted when rate_limits are present:
#   󰦛 5h ▰▰▱▱▱▱▱▱▱▱ 23% (4h 12m) · 󰃭 7d ▰▰▰▰▱▱▱▱▱▱ 41% (3d 5h)
#
# Colors are 24-bit truecolor pulled from the Catppuccin Frappe palette to
# match the terminal theme. Glyphs require a Nerd Font.

input=$(cat)

# ─── Field extraction ────────────────────────────────────────────────────────
j_str() { jq -r "$1 // empty" <<<"$input"; }

R5_PCT=$(j_str   '.rate_limits.five_hour.used_percentage')
R5_RESET=$(j_str '.rate_limits.five_hour.resets_at')
R7_PCT=$(j_str   '.rate_limits.seven_day.used_percentage')
R7_RESET=$(j_str '.rate_limits.seven_day.resets_at')

# Nothing to show — exit silently before doing any more work.
[ -z "$R5_PCT" ] && [ -z "$R7_PCT" ] && exit 0

# ─── Catppuccin Frappe palette (24-bit) ──────────────────────────────────────
RST=$'\033[0m'
DIM=$'\033[2m'
GREEN=$'\033[38;2;166;209;137m'
YELLOW=$'\033[38;2;229;200;144m'
RED=$'\033[38;2;231;130;132m'
LAV=$'\033[38;2;186;187;241m'

SEP="${DIM}·${RST}"

# ─── Helpers ─────────────────────────────────────────────────────────────────
# Strip a decimal so arithmetic works.
to_int() {
  local v=${1:-0}
  v=${v%.*}
  [[ -z $v || ! $v =~ ^-?[0-9]+$ ]] && v=0
  printf '%s' "$v"
}

threshold_color() {
  local p=$1
  if   [ "$p" -ge 90 ]; then printf '%s' "$RED"
  elif [ "$p" -ge 70 ]; then printf '%s' "$YELLOW"
  else                       printf '%s' "$GREEN"
  fi
}

# Build a unicode bar: filled "▰" in $color, empty "▱" dimmed.
make_bar() {
  local pct=$1 width=${2:-10} color=$3
  [ "$pct" -gt 100 ] && pct=100
  [ "$pct" -lt 0   ] && pct=0
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local fbar="" ebar=""
  [ "$filled" -gt 0 ] && printf -v fbar "%${filled}s" "" && fbar=${fbar// /▰}
  [ "$empty"  -gt 0 ] && printf -v ebar "%${empty}s"  "" && ebar=${ebar// /▱}
  printf '%s%s%s%s%s' "$color" "$fbar" "$DIM" "$ebar" "$RST"
}

# Epoch target → relative "3d 5h" / "4h 12m" / "47m" / "now".
fmt_until() {
  local target=$1 now diff
  now=$(date +%s)
  diff=$(( target - now ))
  [ "$diff" -le 0 ] && { printf 'now'; return; }
  local d=$(( diff / 86400 ))
  local h=$(( (diff % 86400) / 3600 ))
  local m=$(( (diff % 3600) / 60 ))
  if   [ "$d" -gt 0 ]; then printf '%dd %dh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then printf '%dh %dm' "$h" "$m"
  else                      printf '%dm' "$m"
  fi
}

join_parts() {
  local out="" first=1
  for p in "$@"; do
    [ -z "$p" ] && continue
    if [ "$first" -eq 1 ]; then out="$p"; first=0
    else                        out="$out $SEP $p"
    fi
  done
  printf '%s' "$out"
}

# ─── Render ──────────────────────────────────────────────────────────────────
parts=()
if [ -n "$R5_PCT" ]; then
  p=$(to_int "$R5_PCT")
  c=$(threshold_color "$p")
  reset=""
  [ -n "$R5_RESET" ] && reset=" ${DIM}($(fmt_until "$R5_RESET"))${RST}"
  parts+=("${LAV}󰦛 5h${RST} $(make_bar "$p" 8 "$c") ${c}${p}%${RST}${reset}")
fi
if [ -n "$R7_PCT" ]; then
  p=$(to_int "$R7_PCT")
  c=$(threshold_color "$p")
  reset=""
  [ -n "$R7_RESET" ] && reset=" ${DIM}($(fmt_until "$R7_RESET"))${RST}"
  parts+=("${LAV}󰃭 7d${RST} $(make_bar "$p" 8 "$c") ${c}${p}%${RST}${reset}")
fi

[ ${#parts[@]} -gt 0 ] && printf '%b\n' "$(join_parts "${parts[@]}")"
