#!/bin/bash
# Move agent to position in room
# Usage: move.sh <x> <y>
source "$(dirname "$0")/_config.sh"

X="${1:?Usage: move.sh <x> <y>}"
Y="${2:?Usage: move.sh <x> <y>}"
api_call POST /api/rooms/move "{\"agent\":\"$AGENT\",\"x\":$X,\"y\":$Y}" >/dev/null || exit 1
echo "🚶 Moved to ($X,$Y)"
