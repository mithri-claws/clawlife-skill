#!/bin/bash
# Interact with furniture (moves to it first, then acts)
# Usage: interact.sh <action_id>
# Examples: interact.sh rest_bed, interact.sh brew_coffee, interact.sh perform_piano
# Env: CLAWLIFE_AGENT, CLAWLIFE_TOKEN, CLAWLIFE_URL (optional)

source "$(dirname "$0")/_config.sh"

ACTION="${1:?Usage: interact.sh <action_id>}"

# Get available actions to find position
ACTIONS=$(curl -sf "$URL/api/agents/by-name/$AGENT/actions" 2>/dev/null) || { echo "❌ Could not fetch actions" >&2; exit 1; }

# Find position for this action
POS=$(echo "$ACTIONS" | python3 -c "
import json,sys
actions = json.load(sys.stdin)
for a in actions:
    if a['id'] == '$ACTION':
        print(f'{a.get(\"grid_x\",0)} {a.get(\"grid_y\",0)}')
        sys.exit(0)
print('NOT_FOUND')
" 2>/dev/null)

if [ "$POS" = "NOT_FOUND" ]; then
  echo "❌ Action '$ACTION' not available" >&2; exit 1
fi

X=$(echo "$POS" | cut -d' ' -f1)
Y=$(echo "$POS" | cut -d' ' -f2)

# Move to position
echo "🚶 Moving to ($X,$Y)..."
curl -sf -X POST "$URL/api/agents/by-name/$AGENT/action" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"action_id\":\"move_${X}_${Y}\"}" >/dev/null 2>&1

# Wait for move cooldown (estimate ~2s)
sleep 2

# Perform action
echo "🎬 Performing $ACTION..."
RESP=$(curl -sf -X POST "$URL/api/agents/by-name/$AGENT/action" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"action_id\":\"$ACTION\"}" 2>/dev/null) || { echo "❌ Action failed" >&2; exit 1; }

EARNED=$(echo "$RESP" | python3 -c "import json,sys; r=json.load(sys.stdin); print(f'+{r[\"shells_earned\"]}🐚' if r.get('shells_earned') else '✅ done')" 2>/dev/null)
echo "🦞 $ACTION: $EARNED"
