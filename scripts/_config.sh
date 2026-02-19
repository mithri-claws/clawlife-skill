#!/bin/bash
# Shared config loader — sourced by all ClawLife scripts

if [ -z "$CLAWLIFE_AGENT" ] || [ -z "$CLAWLIFE_TOKEN" ]; then
  # Try workspace .clawlife using OPENCLAW_STATE_DIR (set by PM2/OpenClaw)
  if [ -n "$OPENCLAW_STATE_DIR" ] && [ -f "$OPENCLAW_STATE_DIR/workspace/.clawlife" ]; then
    source "$OPENCLAW_STATE_DIR/workspace/.clawlife"
  elif [ -f "$HOME/.openclaw/workspace/.clawlife" ]; then
    source "$HOME/.openclaw/workspace/.clawlife"
  elif [ -f "$HOME/.clawlife" ]; then
    source "$HOME/.clawlife"
  fi
fi

CLAWLIFE_URL="${CLAWLIFE_URL:-https://clawlife.world}"

# Short aliases used by scripts
AGENT="$CLAWLIFE_AGENT"
TOKEN="$CLAWLIFE_TOKEN"
URL="$CLAWLIFE_URL"

# Helper: make API call, return body, exit 1 with error message on failure
# Usage: api_call METHOD ENDPOINT [DATA]
# Example: RESP=$(api_call POST /api/rooms/knock '{"visitor":"x","target":"y"}')
api_call() {
  local METHOD="$1" ENDPOINT="$2" DATA="$3"
  local CURL_ARGS=(-s -w "\n%{http_code}" -X "$METHOD" "$URL$ENDPOINT"
    -H "Content-Type: application/json"
    -H "Authorization: Bearer $TOKEN")
  [ -n "$DATA" ] && CURL_ARGS+=(-d "$DATA")

  local RAW; RAW=$(curl "${CURL_ARGS[@]}")
  local HTTP_CODE; HTTP_CODE=$(echo "$RAW" | tail -1)
  local BODY; BODY=$(echo "$RAW" | sed '$d')

  if [ "$HTTP_CODE" -ge 400 ] 2>/dev/null; then
    local ERR; ERR=$(echo "$BODY" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("error","unknown"))' 2>/dev/null || echo "$BODY")
    echo "❌ $ERR" >&2
    return 1
  fi
  echo "$BODY"
}

# Helper: make unauthenticated GET
# Usage: RESP=$(api_get /api/agents)
api_get() {
  local ENDPOINT="$1"
  local RAW; RAW=$(curl -s -w "\n%{http_code}" "$URL$ENDPOINT")
  local HTTP_CODE; HTTP_CODE=$(echo "$RAW" | tail -1)
  local BODY; BODY=$(echo "$RAW" | sed '$d')

  if [ "$HTTP_CODE" -ge 400 ] 2>/dev/null; then
    local ERR; ERR=$(echo "$BODY" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("error","unknown"))' 2>/dev/null || echo "$BODY")
    echo "❌ $ERR" >&2
    return 1
  fi
  echo "$BODY"
}
