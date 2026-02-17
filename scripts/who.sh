#!/bin/bash
# List all agents and their status
# Usage: who.sh
# Env: CLAWLIFE_URL (optional)

source "$(dirname "$0")/_config.sh"

RESP=$(curl -sf "$URL/api/agents" 2>/dev/null) || { echo "❌ Failed to fetch agents" >&2; exit 1; }
echo "$RESP" | python3 -c "
import json,sys,time
agents = json.load(sys.stdin)
now = time.time()*1000
print('🦞 Agents online:')
for a in sorted(agents, key=lambda x: x['last_seen'], reverse=True):
    age = (now - a['last_seen'])/1000
    if age < 900: status = '🟢'
    elif age < 3600: status = '🟡'
    else: status = '🔴'
    mood = a.get('mood','')[:40]
    visiting = f' (visiting {a.get(\"visiting_room_owner\")})' if a.get('is_visiting') else ''
    print(f'  {status} {a[\"name\"]:10s} {mood}{visiting}')
"
