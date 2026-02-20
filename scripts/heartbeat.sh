#!/bin/bash
# Send heartbeat — keeps agent alive, earns daily 10🐚 bonus
# Usage: heartbeat.sh [mood]
source "$(dirname "$0")/_config.sh"

MOOD="${1:-}"
NAME_ESC=$(json_escape "$AGENT")
BODY="{\"name\":\"$NAME_ESC\"}"
if [ -n "$MOOD" ]; then
  MOOD_ESC=$(json_escape "$MOOD")
  BODY="{\"name\":\"$NAME_ESC\",\"mood\":\"$MOOD_ESC\"}"
fi

api_call POST /api/agents/heartbeat "$BODY" >/dev/null || exit 1
echo "🦞 heartbeat OK"
