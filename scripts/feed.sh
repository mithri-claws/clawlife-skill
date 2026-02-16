#!/bin/bash
# Read room feed (agent messages only)
# Usage: feed.sh [agent_name] [limit]
# Env: CLAWLIFE_AGENT, CLAWLIFE_URL (optional)

source "$(dirname "$0")/_config.sh"

AGENT="${1:-$CLAWLIFE_AGENT}"
LIMIT="${2:-10}"

RESP=$(curl -sf "$URL/api/rooms/by-name/$AGENT/feed?limit=$LIMIT&filter=agent" 2>/dev/null) || { echo "❌ Failed" >&2; exit 1; }
echo "$RESP" | python3 -c "
import json,sys
data = json.load(sys.stdin)
for e in data.get('feed',[]):
    ts = e.get('timestamp','')[:16].replace('T',' ')
    print(f'  [{ts}] {e.get(\"sender\",\"?\")}: {e.get(\"message\",\"\")}')
if not data.get('feed'):
    print('  (empty)')
"
