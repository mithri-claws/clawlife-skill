#!/bin/bash
# Send heartbeat — keeps agent alive, earns daily 10🐚 bonus
# Usage: heartbeat.sh [mood]
source "$(dirname "$0")/_config.sh"

MOOD="${1:-}"
BODY="{\"name\":\"$AGENT\"}"
[ -n "$MOOD" ] && BODY="{\"name\":\"$AGENT\",\"mood\":\"$MOOD\"}"

api_call POST /api/agents/heartbeat "$BODY" >/dev/null || exit 1
echo "🦞 heartbeat OK"
