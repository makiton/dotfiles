#!/bin/bash
input=$(cat)

# Use python3 for JSON parsing — always available on WSL/Linux, no jq dependency needed
_jq() {
  echo "$input" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    keys = '$1'.lstrip('.').split('.')
    v = d
    for k in keys:
        v = v.get(k) if isinstance(v, dict) else None
        if v is None:
            break
    print(v if v is not None else '$2')
except Exception:
    print('$2')
" 2>/dev/null
}

MODEL=$(_jq '.model.display_name' 'Claude')
COST=$(_jq '.cost.total_cost_usd' '0')
TOKENS_IN=$(_jq '.context_window.total_input_tokens' '0')
TOKENS_OUT=$(_jq '.context_window.total_output_tokens' '0')
PCT=$(_jq '.context_window.used_percentage' '0')
PCT=$(echo "$PCT" | cut -d. -f1)

# Workspace dir — try JSON first, then fall back to $PWD
DIR=$(_jq '.workspace.current_dir' '')
[ -z "$DIR" ] && DIR=$(_jq '.cwd' '')
[ -z "$DIR" ] && DIR="$PWD"

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

# Cost indicator (useful at work with API key billing)
COST_STR=""
HAS_COST=$(awk -v cost="$COST" 'BEGIN { if (cost+0 > 0) print 1; else print 0 }')
if [ "$HAS_COST" = "1" ]; then
  COST_FMT=$(printf '$%.4f' "$COST")
  COST_STR=" | 💰 ${YELLOW}${COST_FMT}${RESET}"
fi

# Token usage indicator (useful at home with model usage limits)
TOKENS_STR=""
HAS_TOKENS=$(awk -v t="$TOKENS_IN" 'BEGIN { if (t+0 > 0) print 1; else print 0 }')
if [ "$HAS_TOKENS" = "1" ]; then
  IN_K=$(awk -v t="$TOKENS_IN" 'BEGIN { printf "%.1fk", t/1000 }')
  OUT_K=$(awk -v t="$TOKENS_OUT" 'BEGIN { printf "%.1fk", t/1000 }')
  TOKENS_STR=" | 🔢 ${CYAN}${IN_K}↑${OUT_K}↓${RESET}"
fi

echo -e "${CYAN}[$MODEL]${RESET} 📁 ${DIRNAME}${BRANCH} | ${BAR_COLOR}${BAR}${RESET} ${PCT}%${COST_STR}${TOKENS_STR}"
