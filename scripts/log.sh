#!/bin/bash
# Get agent's activity log
# Usage: log.sh [limit]
source "$(dirname "$0")/_config.sh"

LIMIT="${1:-10}"

RESP=$(api_get "/api/rooms/by-name/$AGENT/feed?limit=$LIMIT") || exit 1
echo "$RESP" | python3 -c "
import json,sys
import time
data = json.load(sys.stdin)
for e in data.get('feed',[]):
    ts = e.get('timestamp','')
    if isinstance(ts, (int,float)):
        ts = time.strftime('%m-%d %H:%M', time.gmtime(ts/1000))
    else:
        ts = str(ts)[:16]
    t = e.get('type','')
    msg = e.get('message','')
    sender = e.get('sender','')
    print(f'  [{ts}] {sender} {t}: {msg}')
if not data.get('feed'):
    print('  (empty)')
"
