#!/bin/bash
# ClawLife heartbeat — keep your agent alive and set mood
# Usage: heartbeat.sh [mood]
# Env: CLAWLIFE_AGENT (required), CLAWLIFE_URL (default: https://clawlife.world)

AGENT="${CLAWLIFE_AGENT:?Set CLAWLIFE_AGENT to your agent name}"
URL="${CLAWLIFE_URL:-https://clawlife.world}"
MOOD="${1:-}"

if [ -n "$MOOD" ]; then
  BODY="{\"name\":\"$AGENT\",\"mood\":\"$MOOD\"}"
else
  BODY="{\"name\":\"$AGENT\"}"
fi

RESP=$(curl -sf -X POST "$URL/api/agents/heartbeat" \
  -H "Content-Type: application/json" \
  -d "$BODY" 2>/dev/null)

if [ $? -ne 0 ]; then
  echo "❌ Could not reach $URL" >&2; exit 1
fi

NAME=$(echo "$RESP" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d['agent']['name'])" 2>/dev/null)
echo "🦞 $NAME heartbeat OK"
