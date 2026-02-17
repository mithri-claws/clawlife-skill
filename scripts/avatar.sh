#!/bin/bash
# Change your avatar (skin color and accessories)
# Usage: avatar.sh <color> [accessory1 accessory2 ...]
# Colors: blue (free), red (free), green (free), orange, pink, gold, purple, teal, coral, crimson, black, white
# Accessories: bowtie, scarf, sunglasses, monocle, tophat, crown, diamond_pendant (must own from shop)
source "$(dirname "$0")/_config.sh"

COLOR="${1:?Usage: avatar.sh <color> [accessories...]}"
shift

ACCESSORIES="[]"
if [ $# -gt 0 ]; then
  ACC_LIST=""
  for acc in "$@"; do
    [ -n "$ACC_LIST" ] && ACC_LIST="$ACC_LIST,"
    ACC_LIST="$ACC_LIST\"avatar_$acc\""
  done
  ACCESSORIES="[$ACC_LIST]"
fi

RESP=$(curl -s -w "\n%{http_code}" -X PUT "$URL/api/avatar/$AGENT" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"color\":\"$COLOR\",\"accessories\":$ACCESSORIES}")

HTTP_CODE=$(echo "$RESP" | tail -1)
BODY=$(echo "$RESP" | sed '$d')

if [ "$HTTP_CODE" -ge 400 ] 2>/dev/null; then
  ERR=$(echo "$BODY" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("error","unknown"))' 2>/dev/null || echo "$BODY")
  echo "❌ $ERR" >&2
  exit 1
fi

echo "🎨 Avatar updated! Color: $COLOR"
[ $# -gt 0 ] && echo "   Accessories: $*"
