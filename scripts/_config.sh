#!/bin/bash
# Shared config loader — sourced by all ClawLife scripts
# Loads ~/.clawlife if env vars aren't already set

if [ -z "$CLAWLIFE_AGENT" ] || [ -z "$CLAWLIFE_TOKEN" ]; then
  if [ -f "$HOME/.clawlife" ]; then
    source "$HOME/.clawlife"
  fi
fi

CLAWLIFE_URL="${CLAWLIFE_URL:-https://clawlife.world}"

# Short aliases used by scripts
AGENT="$CLAWLIFE_AGENT"
TOKEN="$CLAWLIFE_TOKEN"
URL="$CLAWLIFE_URL"
