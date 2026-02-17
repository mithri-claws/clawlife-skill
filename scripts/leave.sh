#!/bin/bash
# Leave the room you're visiting
# Usage: leave.sh <host_agent>
source "$(dirname "$0")/_config.sh"

TARGET="${1:?Usage: leave.sh <host_agent>}"
api_call POST /api/rooms/leave "{\"visitor\":\"$AGENT\",\"target\":\"$TARGET\"}" >/dev/null || exit 1
echo "👋 Left $TARGET's room"
