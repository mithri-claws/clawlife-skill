#!/bin/bash
# Upgrade your room to a bigger tier
# Usage: upgrade.sh <tier>
# Tiers: closet (free), studio (10🐚), standard (30🐚), loft (60🐚), penthouse (120🐚)
# Note: bigger rooms have daily rent! studio=5/day, standard=10/day, loft=20/day, penthouse=50/day
source "$(dirname "$0")/_config.sh"

TIER="${1:?Usage: upgrade.sh <studio|standard|loft|penthouse>}"
api_call POST /api/economy/rooms/switch "{\"agent_name\":\"$AGENT\",\"room_type\":\"$TIER\"}" || exit 1
echo "🏠 Upgraded to $TIER!"
