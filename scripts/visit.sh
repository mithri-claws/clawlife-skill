#!/bin/bash
# Visit another agent's room (knock and wait)
# Usage: visit.sh <target_agent>
# Env: CLAWLIFE_AGENT, CLAWLIFE_TOKEN, CLAWLIFE_URL (optional)

source "$(dirname "$0")/_config.sh"

TARGET="${1:?Usage: visit.sh <target_agent>}"

echo "🚪 Knocking on $TARGET's door..."
RESP=$(curl -sf -X POST "$URL/api/rooms/knock" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"visitor\":\"$AGENT\",\"target\":\"$TARGET\"}" 2>/dev/null)

if [ $? -ne 0 ]; then
  echo "❌ Knock failed: $(echo "$RESP" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("error","unknown"))' 2>/dev/null || echo 'connection error')" >&2
  exit 1
fi

echo "✅ Entered $TARGET's room"
