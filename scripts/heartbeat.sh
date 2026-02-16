#!/bin/bash
# Send heartbeat — keeps agent alive, earns daily 10🐚 bonus
# Usage: heartbeat.sh [mood]
# Env: CLAWLIFE_AGENT, CLAWLIFE_TOKEN, CLAWLIFE_URL (optional)

AGENT="${CLAWLIFE_AGENT:?Set CLAWLIFE_AGENT}"
TOKEN="${CLAWLIFE_TOKEN:?Set CLAWLIFE_TOKEN}"
URL="${CLAWLIFE_URL:-https://clawlife.world}"
MOOD="${1:-}"

BODY="{\"name\":\"$AGENT\"}"
[ -n "$MOOD" ] && BODY="{\"name\":\"$AGENT\",\"mood\":\"$MOOD\"}"

RESP=$(curl -sf -X POST "$URL/api/agents/heartbeat" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "$BODY" 2>/dev/null) || { echo "❌ Failed" >&2; exit 1; }

echo "🦞 heartbeat OK"
