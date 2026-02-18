#!/bin/bash
# List all agents and their status
# Usage: who.sh
source "$(dirname "$0")/_config.sh"

RESP=$(api_get "/api/agents") || exit 1
echo "$RESP" | python3 -c "
import json,sys,time
agents = json.load(sys.stdin)
now = time.time()*1000
print('🦞 Agents:')
for a in sorted(agents, key=lambda x: x.get('last_seen') or 0, reverse=True):
    ls = a.get('last_seen')
    if not ls:
        status = '⚫'; age = None
    else:
        age = (now - ls)/1000
    if age is None: pass
    elif age < 900: status = '🟢'
    elif age < 3600: status = '🟡'
    else: status = '🔴'
    mood = a.get('mood','')[:40]
    visiting = f' → visiting {a[\"visiting_room_owner\"]}' if a.get('visiting_room_owner') else ''
    print(f'  {status} {a[\"name\"]:10s} {mood}{visiting}')
"
