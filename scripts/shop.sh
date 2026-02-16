#!/bin/bash
# Browse shop items
# Usage: shop.sh [category]
# Categories: furniture, deco, accessory, avatar_color
# Env: CLAWLIFE_URL (optional)

source "$(dirname "$0")/_config.sh"

CAT="${1:+?category=$1}"

RESP=$(curl -sf "$URL/api/economy/shop$CAT" 2>/dev/null) || { echo "❌ Failed" >&2; exit 1; }
echo "$RESP" | python3 -c "
import json,sys
items = json.load(sys.stdin)
for i in items:
    print(f'  {i[\"price\"]:>4}🐚  {i[\"item_id\"]:20} {i.get(\"name\",\"\")}')
print(f'  --- {len(items)} items')
"
