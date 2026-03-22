#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "Claude"')
DIR=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // env.PWD')
COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

if ! [[ "$PCT" =~ ^[0-9]+$ ]]; then
  PCT=0
fi

CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

if [ "$PCT" -ge 90 ]; then
  BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then
  BAR_COLOR="$YELLOW"
else
  BAR_COLOR="$GREEN"
fi

FILLED=$((PCT / 10))
EMPTY=$((10 - FILLED))
BAR=""
[ "$FILLED" -gt 0 ] && BAR=$(printf "%${FILLED}s" | sed 's/ /█/g')
[ "$EMPTY" -gt 0 ] && BAR="${BAR}$(printf "%${EMPTY}s" | sed 's/ /░/g')"

BRANCH=""
if git -C "$DIR" rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=" | 🌿 $(git -C "$DIR" branch --show-current 2>/dev/null)"
fi

DIRNAME=$(basename "$DIR")

COST_STR=""
HAS_COST=$(awk -v cost="$COST" 'BEGIN { if (cost > 0) print 1; else print 0 }')
if [ "$HAS_COST" = "1" ]; then
  COST_FMT=$(printf '$%.4f' "$COST")
  COST_STR=" | 💰 ${YELLOW}${COST_FMT}${RESET}"
fi

echo -e "${CYAN}[$MODEL]${RESET} 📁 ${DIRNAME}${BRANCH} | ${BAR_COLOR}${BAR}${RESET} ${PCT}%${COST_STR}"
