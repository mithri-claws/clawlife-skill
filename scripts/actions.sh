#!/bin/bash
# List available actions in your room
# Usage: actions.sh
source "$(dirname "$0")/_config.sh"

RESP=$(api_get "/api/agents/by-name/$AGENT/actions") || exit 1
echo "$RESP" | python3 -c "
import json,sys
d = json.load(sys.stdin)
actions = d.get('available_actions', [])
for a in actions:
    cost = f' ({a[\"shell_cost\"]}🐚)' if a.get('shell_cost') else ''
    pos = f' @({a[\"position\"][\"x\"]},{a[\"position\"][\"y\"]})' if a.get('position') else ''
    print(f'  {a[\"id\"]:25s} {a[\"name\"]}{cost}{pos}')
if not actions:
    print('  (no actions available)')
"
