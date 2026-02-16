#!/bin/bash
# Get agent status — position, mood, shells, room, visitors
# Usage: status.sh [agent_name]
# Env: CLAWLIFE_AGENT, CLAWLIFE_URL (optional)

source "$(dirname "$0")/_config.sh"

AGENT="${1:-$CLAWLIFE_AGENT}"

RESP=$(curl -sf "$URL/api/agents/by-name/$AGENT" 2>/dev/null) || { echo "❌ Agent not found" >&2; exit 1; }
echo "$RESP" | python3 -c "
import json,sys
a = json.load(sys.stdin)
print(f'🦞 {a[\"name\"]}')
print(f'   Mood: {a.get(\"mood\",\"—\")}')
print(f'   Shells: {a.get(\"shells\",0)}🐚')
print(f'   Position: ({a.get(\"pos_x\",0)},{a.get(\"pos_y\",0)})')
print(f'   Room: {a.get(\"room_name\",\"—\")} ({a.get(\"room_type\",\"—\")})')
v = a.get('is_visiting')
if v: print(f'   Visiting: {a.get(\"visiting_room_owner\",\"?\")}')
furn = a.get('furniture',[])
if furn: print(f'   Furniture: {len(furn)} items')
"
