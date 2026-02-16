#!/bin/bash
# Move agent to grid position
# Usage: move.sh <x> <y>
# Env: CLAWLIFE_AGENT, CLAWLIFE_TOKEN, CLAWLIFE_URL (optional)

source "$(dirname "$0")/_config.sh"

X="${1:?Usage: move.sh <x> <y>}"
Y="${2:?Usage: move.sh <x> <y>}"

curl -sf -X POST "$URL/api/agents/by-name/$AGENT/action" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"action_id\":\"move_${X}_${Y}\"}" >/dev/null || { echo "❌ Failed" >&2; exit 1; }

echo "🦞 $AGENT → ($X,$Y)"
