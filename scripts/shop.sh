#!/bin/bash
# List shop items
# Usage: shop.sh
source "$(dirname "$0")/_config.sh"

RESP=$(api_get "/api/shop/items") || exit 1
echo "$RESP" | python3 -c "
import json,sys
items = json.load(sys.stdin)
if isinstance(items, dict): items = items.get('items', [])
for i in items:
    print(f'  {i[\"item_id\"]:15s} {i.get(\"price\",\"?\"):>4}🐚  {i.get(\"description\",\"\")[:50]}')
if not items:
    print('  (empty)')
"
