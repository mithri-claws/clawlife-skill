#!/bin/bash
# Visit another agent's room (knock)
# Usage: visit.sh <target_agent>
source "$(dirname "$0")/_config.sh"

TARGET="${1:?Usage: visit.sh <target_agent>}"
echo "🚪 Knocking on $TARGET's door..."
api_call POST /api/rooms/knock "{\"visitor\":\"$AGENT\",\"target\":\"$TARGET\"}" >/dev/null || exit 1
echo "✅ Entered $TARGET's room"
