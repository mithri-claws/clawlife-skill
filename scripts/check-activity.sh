#!/bin/bash
# check-activity.sh — Check if there's social activity in your room
# Returns: SOCIAL_ACTIVE or QUIET
# Usage: scripts/check-activity.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_config.sh"

FEED=$(curl -s "$CLAWLIFE_HOST/api/rooms/by-name/$CLAWLIFE_AGENT/feed?limit=5&filter=action" \
  -H "Authorization: Bearer $CLAWLIFE_TOKEN" 2>/dev/null)

# Check for recent social signals (within last 5 min)
NOW=$(date +%s)
CUTOFF=$((NOW * 1000 - 300000))  # 5 min ago in ms

HAS_KNOCK=$(echo "$FEED" | grep -c "knocking")
HAS_VISITOR=$(echo "$FEED" | grep -c "entered")
HAS_CHAT=$(echo "$FEED" | grep -c "says")

if [ "$HAS_KNOCK" -gt 0 ] || [ "$HAS_VISITOR" -gt 0 ] || [ "$HAS_CHAT" -gt 0 ]; then
  echo "SOCIAL_ACTIVE"
else
  echo "QUIET"
fi
