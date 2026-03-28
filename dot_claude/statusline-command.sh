#!/bin/bash
input=$(cat)

# Use python3 for JSON parsing — always available on WSL/Linux, no jq needed
_jq() {
  local path="$1" default="${2:-}"
  echo "$input" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    keys = '${path}'.lstrip('.').split('.')
    v = d
    for k in keys:
        v = v.get(k) if isinstance(v, dict) else None
        if v is None:
            break
    print(v if v is not None else '${default}')
except Exception:
    print('${default}')
" 2>/dev/null
}

MODEL=$(_jq '.model.display_name' 'Claude')
COST=$(_jq '.cost.total_cost_usd' '0')
PCT=$(_jq '.context_window.used_percentage' '0')
PCT=$(echo "$PCT" | cut -d. -f1)
FIVE_H=$(_jq '.rate_limits.five_hour.used_percentage' '')
SEVEN_D=$(_jq '.rate_limits.seven_day.used_percentage' '')

# Workspace dir — JSON first, then fall back to $PWD
DIR=$(_jq '.workspace.current_dir' '')
[ -z "$DIR" ] && DIR=$(_jq '.cwd' '')
[ -z "$DIR" ] && DIR="$PWD"

if ! [[ "$PCT" =~ ^[0-9]+$ ]]; then PCT=0; fi

CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# Build a 5-block mini bar for a given percentage (0-100)
mini_bar() {
  local pct="${1:-0}"
  local filled=$(( pct * 5 / 100 ))
  local empty=$(( 5 - filled ))
  local bar=""
  [ "$filled" -gt 0 ] && bar=$(printf "%${filled}s" | sed 's/ /█/g')
  [ "$empty"  -gt 0 ] && bar="${bar}$(printf "%${empty}s" | sed 's/ /░/g')"
  echo "$bar"
}

# Color by percentage
pct_color() {
  local pct="${1:-0}"
  if   [ "$pct" -ge 90 ]; then echo "$RED"
  elif [ "$pct" -ge 70 ]; then echo "$YELLOW"
  else                          echo "$GREEN"
  fi
}

# Context window bar (10 blocks)
CW_FILLED=$((PCT / 10))
CW_EMPTY=$((10 - CW_FILLED))
CW_BAR=""
[ "$CW_FILLED" -gt 0 ] && CW_BAR=$(printf "%${CW_FILLED}s" | sed 's/ /█/g')
[ "$CW_EMPTY"  -gt 0 ] && CW_BAR="${CW_BAR}$(printf "%${CW_EMPTY}s" | sed 's/ /░/g')"
CW_COLOR=$(pct_color "$PCT")

# Git branch
BRANCH=""
if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=" | 🌿 $(git -C "$DIR" branch --show-current 2>/dev/null)"
fi

DIRNAME=$(basename "$DIR")

# Cost indicator (useful at work with API key billing)
COST_STR=""
HAS_COST=$(awk -v c="$COST" 'BEGIN { print (c+0 > 0) ? 1 : 0 }')
if [ "$HAS_COST" = "1" ]; then
  COST_FMT=$(printf '$%.4f' "$COST")
  COST_STR=" | 💰 ${YELLOW}${COST_FMT}${RESET}"
fi

# Rate limit bars — 5h rolling window and 7d rolling window
# Only shown when rate_limits data is present (requires Claude Max plan)
RATE_STR=""
if [ -n "$FIVE_H" ] && [ "$FIVE_H" != "None" ]; then
  FH_INT=$(printf '%.0f' "$FIVE_H")
  FH_COLOR=$(pct_color "$FH_INT")
  FH_BAR=$(mini_bar "$FH_INT")
  RATE_STR="${RATE_STR} | 5h:${FH_COLOR}${FH_BAR}${RESET}${FH_INT}%"
fi
if [ -n "$SEVEN_D" ] && [ "$SEVEN_D" != "None" ]; then
  SD_INT=$(printf '%.0f' "$SEVEN_D")
  SD_COLOR=$(pct_color "$SD_INT")
  SD_BAR=$(mini_bar "$SD_INT")
  RATE_STR="${RATE_STR} 7d:${SD_COLOR}${SD_BAR}${RESET}${SD_INT}%"
fi

echo -e "${CYAN}[$MODEL]${RESET} 📁 ${DIRNAME}${BRANCH} | ${CW_COLOR}${CW_BAR}${RESET} ${PCT}%${COST_STR}${RATE_STR}"
