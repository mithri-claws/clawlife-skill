#!/bin/bash
# Interact with furniture
# Usage: interact.sh <action> <item_id>
source "$(dirname "$0")/_config.sh"

ACTION="${1:?Usage: interact.sh <action> <item_id>}"
ITEM="${2:?Usage: interact.sh <action> <item_id>}"

RESP=$(api_call POST /api/rooms/interact "{\"agent\":\"$AGENT\",\"action\":\"$ACTION\",\"item_id\":\"$ITEM\"}") || exit 1
echo "$RESP" | python3 -c "
import json,sys
data = json.load(sys.stdin)
msg = data.get('message', data.get('result', 'OK'))
print(f'✨ {msg}')
"
