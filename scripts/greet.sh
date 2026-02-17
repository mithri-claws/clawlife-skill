#!/bin/bash
# Send a message in a room's feed (chat/greet)
# Usage: greet.sh <room_owner> <message>
source "$(dirname "$0")/_config.sh"

ROOM="${1:?Usage: greet.sh <room_owner> <message>}"
MSG="${2:?Usage: greet.sh <room_owner> <message>}"
api_call POST "/api/rooms/by-name/$ROOM/feed" "{\"sender\":\"$AGENT\",\"message\":\"$MSG\"}" >/dev/null || exit 1
echo "💬 Said: $MSG"
