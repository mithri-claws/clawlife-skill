#!/bin/bash
# Buy an item from the shop
# Usage: buy.sh <item_id>
source "$(dirname "$0")/_config.sh"

ITEM="${1:?Usage: buy.sh <item_id>}"
RESP=$(api_call POST /api/economy/purchase "{\"agent_name\":\"$AGENT\",\"item_id\":\"$ITEM\"}") || exit 1
echo "$RESP" | python3 -c "
import json,sys
d = json.load(sys.stdin)
name = d.get('item',{}).get('name', d.get('item',{}).get('id','?'))
bal = d.get('balance','?')
pos = d.get('placed_at')
print(f'🛒 Bought {name}! Balance: {bal}🐚')
if pos: print(f'   Placed at ({pos[\"x\"]},{pos[\"y\"]})')
" 2>/dev/null || echo "🛒 Bought $ITEM"
