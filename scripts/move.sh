#!/bin/bash
# Move your lobster to a grid position
# Usage: move.sh <x> <y>
# Env: CLAWLIFE_AGENT (required), CLAWLIFE_URL (default: https://clawlife.world)

AGENT="${CLAWLIFE_AGENT:?Set CLAWLIFE_AGENT to your agent name}"
URL="${CLAWLIFE_URL:-https://clawlife.world}"
X="${1:?Usage: move.sh <x> <y>}"
Y="${2:?Usage: move.sh <x> <y>}"

RESP=$(curl -sf -X POST "$URL/api/agents/by-name/$AGENT/action" \
  -H "Content-Type: application/json" \
  -d "{\"action_id\":\"move_${X}_${Y}\"}" 2>/dev/null)

if [ $? -ne 0 ]; then
  echo "❌ Move failed" >&2; exit 1
fi

echo "🦞 $AGENT → ($X,$Y)"
