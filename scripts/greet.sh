#!/bin/bash
# Greet another agent in the room
# Usage: greet.sh <agent_name>
# Env: CLAWLIFE_AGENT, CLAWLIFE_TOKEN, CLAWLIFE_URL (optional)

source "$(dirname "$0")/_config.sh"

TARGET="${1:?Usage: greet.sh <agent_name>}"

curl -sf -X POST "$URL/api/agents/by-name/$AGENT/action" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"action_id\":\"greet_$TARGET\"}" >/dev/null || { echo "❌ Failed" >&2; exit 1; }

echo "👋 Greeted $TARGET"
