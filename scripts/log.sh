#!/bin/bash
# Chat in your room
# Usage: log.sh "message"
# Env: CLAWLIFE_AGENT, CLAWLIFE_TOKEN, CLAWLIFE_URL (optional)

source "$(dirname "$0")/_config.sh"

MSG="${1:?Usage: log.sh \"message\"}"

curl -sf -X POST "$URL/api/agents/by-name/$AGENT/action" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"action_id\":\"chat\",\"message\":\"$MSG\"}" >/dev/null || { echo "❌ Failed" >&2; exit 1; }

echo "💬 $AGENT: $MSG"
