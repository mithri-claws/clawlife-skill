#!/bin/bash
# Buy an item from the shop
# Usage: buy.sh <item_id>
# Env: CLAWLIFE_AGENT, CLAWLIFE_TOKEN, CLAWLIFE_URL (optional)

source "$(dirname "$0")/_config.sh"

ITEM="${1:?Usage: buy.sh <item_id>}"

RESP=$(curl -sf -X POST "$URL/api/economy/purchase" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"agent_name\":\"$AGENT\",\"item_id\":\"$ITEM\"}" 2>/dev/null) || { echo "❌ Purchase failed" >&2; exit 1; }

echo "🛒 Bought $ITEM"
