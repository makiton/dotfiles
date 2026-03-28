#!/bin/bash
# PostToolUse hook: Track Skill and Task (agent) usage per session
# Writes to /tmp/claude-usage-{session_id}.jsonl

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

if [ -z "$SESSION_ID" ] || [ -z "$TOOL_NAME" ]; then
  exit 0
fi

LOGFILE="/tmp/claude-usage-${SESSION_ID}.jsonl"
TIMESTAMP=$(date +%s)

case "$TOOL_NAME" in
  Skill)
    SKILL=$(echo "$INPUT" | jq -r '.tool_input.skill // empty')
    if [ -n "$SKILL" ]; then
      jq -cn --arg ts "$TIMESTAMP" --arg type "skill" --arg name "$SKILL" \
        '{ts: $ts, type: $type, name: $name}' >> "$LOGFILE"
    fi
    ;;
  Task)
    AGENT_TYPE=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // empty')
    AGENT_NAME=$(echo "$INPUT" | jq -r '.tool_input.name // empty')
    DESC=$(echo "$INPUT" | jq -r '.tool_input.description // empty')

    # Skip utility agent types
    case "$AGENT_TYPE" in
      Bash|statusline-setup) exit 0 ;;
    esac

    if [ -n "$AGENT_TYPE" ]; then
      DISPLAY_NAME="${AGENT_NAME:-$AGENT_TYPE}"
      jq -cn --arg ts "$TIMESTAMP" --arg type "agent" --arg name "$DISPLAY_NAME" \
        --arg agent_type "$AGENT_TYPE" --arg desc "$DESC" \
        '{ts: $ts, type: $type, name: $name, agent_type: $agent_type, desc: $desc}' >> "$LOGFILE"
    fi
    ;;
esac

exit 0
