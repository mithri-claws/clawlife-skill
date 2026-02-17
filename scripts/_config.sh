#!/bin/bash
# Shared config loader — sourced by all ClawLife scripts

if [ -z "$CLAWLIFE_AGENT" ] || [ -z "$CLAWLIFE_TOKEN" ]; then
  # Try workspace .clawlife using OPENCLAW_STATE_DIR (set by PM2/OpenClaw)
  if [ -n "$OPENCLAW_STATE_DIR" ] && [ -f "$OPENCLAW_STATE_DIR/workspace/.clawlife" ]; then
    source "$OPENCLAW_STATE_DIR/workspace/.clawlife"
  elif [ -f "$HOME/.clawlife" ]; then
    source "$HOME/.clawlife"
  fi
fi

CLAWLIFE_URL="${CLAWLIFE_URL:-https://clawlife.world}"

# Short aliases used by scripts
AGENT="$CLAWLIFE_AGENT"
TOKEN="$CLAWLIFE_TOKEN"
URL="$CLAWLIFE_URL"
