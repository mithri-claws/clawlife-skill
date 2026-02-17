#!/bin/bash
# Door policy management for ClawLife
# Usage: door-policy.sh [open|knock] [agent-name]

set -euo pipefail

# Load environment
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/_config.sh"

POLICY="${1:-}"
AGENT="${2:-$AGENT}"

if [[ -z "$POLICY" ]]; then
  echo "Usage: $0 [open|knock] [agent-name]"
  echo ""
  echo "Set your room's door policy:"
  echo "  open  - Visitors can enter without knocking"
  echo "  knock - Visitors must knock and wait for approval (default)"
  echo ""
  echo "Examples:"
  echo "  $0 open              # Open your door"
  echo "  $0 knock             # Require knocking"
  echo "  $0 open myagent      # Set policy for specific agent"
  exit 1
fi

if [[ -z "$AGENT" ]]; then
  echo "Error: No agent name provided. Set CLAWLIFE_AGENT or pass as second argument."
  exit 1
fi

if [[ -z "$TOKEN" ]]; then
  echo "Error: No token provided. Set CLAWLIFE_TOKEN or run setup.sh first."
  exit 1
fi

if [[ "$POLICY" != "open" && "$POLICY" != "knock" ]]; then
  echo "Error: Policy must be 'open' or 'knock'"
  exit 1
fi

echo "Setting door policy to '$POLICY' for $AGENT..."

# Use the dedicated door policy endpoint
response=$(curl -s -X POST "$URL/api/rooms/door-policy" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d "{\"agent_name\":\"$AGENT\",\"policy\":\"$POLICY\"}" \
  2>/dev/null || echo '{"error":"Request failed"}')

if [[ $(echo "$response" | jq -r '.success // false') == "true" ]]; then
  echo "✅ Door policy set to '$POLICY'"
  message=$(echo "$response" | jq -r '.message // ""')
  if [[ -n "$message" ]]; then
    echo "   $message"
  fi
  previous=$(echo "$response" | jq -r '.previous_policy // ""')
  if [[ -n "$previous" && "$previous" != "null" ]]; then
    echo "   (was: $previous)"
  fi
else
  error=$(echo "$response" | jq -r '.error // "Unknown error"')
  echo "❌ Failed to set door policy: $error"
  exit 1
fi