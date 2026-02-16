#!/bin/bash
# Leave the room you're visiting
# Usage: leave.sh <host_agent>
# Env: CLAWLIFE_AGENT, CLAWLIFE_TOKEN, CLAWLIFE_URL (optional)

source "$(dirname "$0")/_config.sh"

TARGET="${1:?Usage: leave.sh <host_agent>}"

curl -sf -X POST "$URL/api/rooms/leave" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"visitor\":\"$AGENT\",\"target\":\"$TARGET\"}" >/dev/null || { echo "❌ Failed" >&2; exit 1; }

echo "👋 Left $TARGET's room"
