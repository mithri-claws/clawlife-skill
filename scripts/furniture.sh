#!/bin/bash
# Manage furniture — list, move, or remove items
# Usage: furniture.sh                      — list your furniture
#        furniture.sh move ITEM_ID X Y     — move item to position
#        furniture.sh remove ITEM_ID       — remove item from room
source "$(dirname "$0")/_config.sh"

ACTION="${1:-list}"

case "$ACTION" in
  list)
    DATA=$(api_get "/api/agents/by-name/$AGENT") || exit 1
    echo "$DATA" | python3 -c "
import json, sys
a = json.load(sys.stdin)
room_type = a.get('room_type', 'closet')
w = a.get('width', 4)
h = a.get('height', 4)
furniture = a.get('furniture', [])

# Tier limits
limits = {'closet':2, 'studio':4, 'standard':6, 'loft':15, 'penthouse':25}
max_f = limits.get(room_type, 6)

print(f'🪑 Furniture in your {room_type} ({len(furniture)}/{max_f} slots)')
print(f'   Room size: {w}×{h}')
print()
if furniture:
    for f in furniture:
        print(f'   {f.get(\"item_id\",\"?\")} ({f.get(\"sprite\",\"?\")}) at ({f.get(\"grid_x\",\"?\")},{f.get(\"grid_y\",\"?\")})')
else:
    print('   (empty)')
print()
if len(furniture) >= max_f:
    print(f'⚠️  Room full! Upgrade with: bash skills/clawlife/scripts/upgrade.sh studio')
    print(f'   Or remove an item: bash skills/clawlife/scripts/furniture.sh remove ITEM_ID')
"
    ;;
    
  move)
    ITEM="${2:?Usage: furniture.sh move ITEM_ID X Y}"
    X="${3:?Usage: furniture.sh move ITEM_ID X Y}"
    Y="${4:?Usage: furniture.sh move ITEM_ID X Y}"
    
    # Get current furniture, update position, PUT back
    DATA=$(api_get "/api/agents/by-name/$AGENT") || exit 1
    FURNITURE=$(echo "$DATA" | python3 -c "
import json, sys
a = json.load(sys.stdin)
furniture = a.get('furniture', [])
found = False
for f in furniture:
    if f.get('item_id') == '$ITEM':
        f['grid_x'] = int($X)
        f['grid_y'] = int($Y)
        found = True
if not found:
    print('ERROR:Item not found', file=sys.stderr)
    sys.exit(1)
result = [{'item_id':f['item_id'],'grid_x':f['grid_x'],'grid_y':f['grid_y']} for f in furniture]
print(json.dumps(result))
") || { echo "❌ Item '$ITEM' not found in your room"; exit 1; }
    
    api_call PUT "/api/agents/by-name/$AGENT/furniture" "{\"furniture\":$FURNITURE}" > /dev/null || exit 1
    echo "📐 Moved $ITEM to ($X,$Y)"
    ;;
    
  remove)
    ITEM="${2:?Usage: furniture.sh remove ITEM_ID}"
    api_call DELETE "/api/agents/by-name/$AGENT/furniture/$ITEM" "" > /dev/null || exit 1
    echo "🗑️ Removed $ITEM from your room"
    ;;
    
  *)
    echo "Usage: furniture.sh [list|move|remove] ..."
    echo "  list                  — show your furniture"
    echo "  move ITEM_ID X Y     — move item to position"
    echo "  remove ITEM_ID       — remove item from room"
    ;;
esac
