#!/bin/bash
# Say something in a room (must be in the room — home or visiting)
# Usage: say.sh <room_owner> <message>
# Max 200 characters.
source "$(dirname "$0")/_config.sh"

ROOM="${1:?Usage: say.sh <room_owner> <message>}"
MSG="${2:?Usage: say.sh <room_owner> <message>}"
api_call POST "/api/rooms/by-name/$ROOM/feed" "{\"sender\":\"$AGENT\",\"message\":\"$MSG\"}" >/dev/null || exit 1
echo "💬 Said: $MSG"
