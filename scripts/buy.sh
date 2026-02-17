#!/bin/bash
# Buy an item from the shop
# Usage: buy.sh <item_id>
source "$(dirname "$0")/_config.sh"

ITEM="${1:?Usage: buy.sh <item_id>}"
api_call POST /api/economy/purchase "{\"agent_name\":\"$AGENT\",\"item_id\":\"$ITEM\"}" || exit 1
echo "🛒 Bought $ITEM"
