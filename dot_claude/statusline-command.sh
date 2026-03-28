#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // env.PWD')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
# "// empty" produces empty string when the field is absent (rate_limits not on all plans)
FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
SEVEN_D=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

if ! [[ "$PCT" =~ ^[0-9]+$ ]]; then PCT=0; fi

CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# Pick a color based on percentage
pct_color() {
  local pct="${1:-0}"
  if   [ "$pct" -ge 90 ]; then printf '%s' "$RED"
  elif [ "$pct" -ge 70 ]; then printf '%s' "$YELLOW"
  else                         printf '%s' "$GREEN"
  fi
}

# Build a bar of given width filled to the given percentage
make_bar() {
  local pct="${1:-0}" width="${2:-10}"
  local filled=$(( pct * width / 100 ))
  local empty=$(( width - filled ))
  local bar=""
  [ "$filled" -gt 0 ] && bar=$(printf "%${filled}s" | sed 's/ /█/g')
  [ "$empty"  -gt 0 ] && bar="${bar}$(printf "%${empty}s" | sed 's/ /░/g')"
  printf '%s' "$bar"
}

# Context window bar (10 blocks)
CW_COLOR=$(pct_color "$PCT")
CW_BAR=$(make_bar "$PCT" 10)

# Git branch
BRANCH=""
if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=" | 🌿 $(git -C "$DIR" branch --show-current 2>/dev/null)"
fi

DIRNAME=$(basename "$DIR")

# Cost indicator
COST_STR=""
HAS_COST=$(awk -v c="$COST" 'BEGIN { print (c+0 > 0) ? 1 : 0 }')
if [ "$HAS_COST" = "1" ]; then
  COST_FMT=$(printf '$%.4f' "$COST")
  COST_STR=" | 💰 ${YELLOW}${COST_FMT}${RESET}"
fi

# Rate limit bars — 5h rolling window and 7d rolling window
# Only shown when rate_limits data is present (requires Claude Max plan)
RATE_STR=""
if [ -n "$FIVE_H" ]; then
  FH_INT=$(printf '%.0f' "$FIVE_H")
  FH_COLOR=$(pct_color "$FH_INT")
  FH_BAR=$(make_bar "$FH_INT" 5)
  RATE_STR=" | 5h:${FH_COLOR}${FH_BAR}${RESET}${FH_INT}%"
fi
if [ -n "$SEVEN_D" ]; then
  SD_INT=$(printf '%.0f' "$SEVEN_D")
  SD_COLOR=$(pct_color "$SD_INT")
  SD_BAR=$(make_bar "$SD_INT" 5)
  RATE_STR="${RATE_STR} 7d:${SD_COLOR}${SD_BAR}${RESET}${SD_INT}%"
fi

echo -e "${CYAN}[$MODEL]${RESET} 📁 ${DIRNAME}${BRANCH} | ${CW_COLOR}${CW_BAR}${RESET} ${PCT}%${COST_STR}${RATE_STR}"
