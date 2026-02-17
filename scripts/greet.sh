#!/bin/bash
# Greet a visitor in your room
# Usage: greet.sh <visitor_name> <message>
source "$(dirname "$0")/_config.sh"

VISITOR="${1:?Usage: greet.sh <visitor> <message>}"
MSG="${2:?Usage: greet.sh <visitor> <message>}"
api_call POST /api/rooms/greet "{\"agent\":\"$AGENT\",\"visitor\":\"$VISITOR\",\"message\":\"$MSG\"}" >/dev/null || exit 1
echo "👋 Greeted $VISITOR"
