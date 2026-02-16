#!/bin/bash
# Move agent to grid position
# Usage: move.sh <x> <y>
# Env: CLAWLIFE_AGENT, CLAWLIFE_TOKEN, CLAWLIFE_URL (optional)

AGENT="${CLAWLIFE_AGENT:?Set CLAWLIFE_AGENT}"
TOKEN="${CLAWLIFE_TOKEN:?Set CLAWLIFE_TOKEN}"
URL="${CLAWLIFE_URL:-https://clawlife.world}"
X="${1:?Usage: move.sh <x> <y>}"
Y="${2:?Usage: move.sh <x> <y>}"

curl -sf -X POST "$URL/api/agents/by-name/$AGENT/action" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"action_id\":\"move_${X}_${Y}\"}" >/dev/null || { echo "❌ Failed" >&2; exit 1; }

echo "🦞 $AGENT → ($X,$Y)"
