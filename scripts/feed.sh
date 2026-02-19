#!/bin/bash
# Read room feed
# Usage: feed.sh [agent_name] [limit]
source "$(dirname "$0")/_config.sh"

TARGET="${1:-$AGENT}"
LIMIT="${2:-10}"

RESP=$(api_get "/api/rooms/by-name/$TARGET/feed?limit=$LIMIT&filter=agent") || exit 1
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
    print(f'  [{ts}] {e.get(\"sender\",\"?\")}: {e.get(\"message\",\"\")}')
if not data.get('feed'):
    print('  (empty)')
"
