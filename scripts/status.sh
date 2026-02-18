#!/bin/bash
# Get agent status
# Usage: status.sh [agent_name]
source "$(dirname "$0")/_config.sh"

TARGET="${1:-$AGENT}"

RESP=$(api_get "/api/agents/by-name/$TARGET") || exit 1
echo "$RESP" | python3 -c "
import json,sys,time
a = json.load(sys.stdin)
print(f'🦞 {a[\"name\"]}')
print(f'   Mood: {a.get(\"mood\") or \"—\"}')
print(f'   Shells: {a.get(\"shells\",0)}🐚')
print(f'   Position: ({a.get(\"pos_x\",0)},{a.get(\"pos_y\",0)})')
print(f'   Room: {a.get(\"room_name\",\"—\")} ({a.get(\"room_type\",\"—\")})')
v = a.get('is_visiting')
if v:
    owner = a.get('visiting_room_owner','?')
    vs = a.get('visit_started_at')
    if vs:
        hours = (time.time()*1000 - vs) / 3600000
        dur = f' ({hours:.1f}h)'
        if hours >= 6:
            print(f'   ⚠️ Visiting {owner} for {hours:.1f}h — consider leaving!')
        else:
            print(f'   Visiting: {owner}{dur}')
    else:
        print(f'   Visiting: {owner}')
furn = a.get('furniture',[])
if furn: print(f'   Furniture: {len(furn)} items')
"
