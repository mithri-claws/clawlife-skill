#!/bin/bash
# Integration tests for ClawLife Skill API
# Verifies every endpoint documented in SKILL.md works against a running instance.
# Usage: CLAWLIFE_URL=http://localhost:4000 bash skill-api.test.sh
# Exit code: 0 = all pass, 1 = failures

URL="${CLAWLIFE_URL:-http://localhost:4000}"
AGENT="skill-test-$(date +%s)"
EMAIL="skilltest-$(date +%s)@test.com"
PASS=0
FAIL=0
TOKEN=""

pass() { PASS=$((PASS+1)); echo "  ✅ $1"; }
fail() { FAIL=$((FAIL+1)); echo "  ❌ $1: $2"; }

check_json() {
  # $1=description, $2=response, $3=expected key to exist
  local desc="$1" resp="$2" key="$3"
  if echo "$resp" | python3 -c "import sys,json; d=json.load(sys.stdin); assert '$key' in d or any('$key' in str(v) for v in d.values())" 2>/dev/null; then
    pass "$desc"
  else
    fail "$desc" "missing '$key' in response"
  fi
}

check_status() {
  # $1=description, $2=http_code, $3=expected code
  if [ "$2" = "$3" ]; then pass "$1"; else fail "$1" "expected $3 got $2"; fi
}

echo ""
echo "🦞 ClawLife Skill API Tests"
echo "   Target: $URL"
echo "   Agent:  $AGENT"
echo ""

# ========== HEALTH ==========
echo "── Health ──"
RESP=$(curl -sf "$URL/health" 2>/dev/null)
check_json "GET /health returns status" "$RESP" "status"

# ========== AUTH ==========
echo "── Auth ──"

# Register
RESP=$(curl -sf -X POST "$URL/api/auth/register" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$AGENT\",\"email\":\"$EMAIL\"}" 2>/dev/null)
check_json "POST /auth/register" "$RESP" "token"
TOKEN=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin).get('token',''))" 2>/dev/null)

if [ -z "$TOKEN" ]; then
  fail "Token extraction" "no token returned"
  echo "⛔ Cannot continue without auth token"; exit 1
fi

# Login
RESP=$(curl -sf -X POST "$URL/api/auth/login" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$EMAIL\"}" 2>/dev/null)
check_json "POST /auth/login" "$RESP" "token"

# Verify
RESP=$(curl -sf "$URL/api/auth/me" -H "Authorization: Bearer $TOKEN" 2>/dev/null)
check_json "GET /auth/me" "$RESP" "agent_name"

# ========== AGENTS ==========
echo "── Agents ──"

# List agents (returns array)
RESP=$(curl -sf "$URL/api/agents" 2>/dev/null)
if echo "$RESP" | python3 -c "import sys,json; d=json.load(sys.stdin); assert isinstance(d, list)" 2>/dev/null; then
  pass "GET /agents"
else
  fail "GET /agents" "expected array"
fi

# Get agent by name
RESP=$(curl -sf "$URL/api/agents/by-name/$AGENT" 2>/dev/null)
check_json "GET /agents/by-name/:name" "$RESP" "name"
check_json "  includes shells" "$RESP" "shells"
check_json "  includes room_id" "$RESP" "room_id"

# Heartbeat
RESP=$(curl -sf -X POST "$URL/api/agents/heartbeat" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$AGENT\",\"mood\":\"testing\"}" 2>/dev/null)
check_json "POST /agents/heartbeat" "$RESP" "success"

# Heartbeat mood validation
CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$URL/api/agents/heartbeat" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"$AGENT\",\"mood\":\"$(python3 -c "print('x'*51)")\"}" 2>/dev/null)
check_status "Heartbeat rejects mood >50 chars" "$CODE" "400"

# Actions list
RESP=$(curl -sf "$URL/api/agents/by-name/$AGENT/actions" 2>/dev/null)
if echo "$RESP" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
  pass "GET /agents/by-name/:name/actions"
else
  fail "GET /agents/by-name/:name/actions" "invalid json"
fi

# Move action
RESP=$(curl -sf -X POST "$URL/api/agents/by-name/$AGENT/action" \
  -H "Content-Type: application/json" \
  -d '{"action_id":"move_3_5"}' 2>/dev/null)
check_json "POST action move_3_5" "$RESP" "success"

# ========== ECONOMY ==========
echo "── Economy ──"

# Balance
RESP=$(curl -sf "$URL/api/economy/balance/$AGENT" 2>/dev/null)
check_json "GET /economy/balance/:name" "$RESP" "shells"

# History
RESP=$(curl -sf "$URL/api/economy/history/$AGENT" 2>/dev/null)
check_json "GET /economy/history/:name" "$RESP" "history"

# Shop (all)
RESP=$(curl -sf "$URL/api/economy/shop" 2>/dev/null)
check_json "GET /economy/shop" "$RESP" "shop"

# Shop (filtered)
RESP=$(curl -sf "$URL/api/economy/shop?category=furniture" 2>/dev/null)
check_json "GET /economy/shop?category=furniture" "$RESP" "shop"

# Shop item detail
RESP=$(curl -sf "$URL/api/economy/shop/furn_rug" 2>/dev/null)
if echo "$RESP" | python3 -c "import sys,json; d=json.load(sys.stdin); assert d.get('name') or d.get('item',{}).get('name')" 2>/dev/null; then
  pass "GET /economy/shop/:itemId"
else
  fail "GET /economy/shop/:itemId" "no item data"
fi

# Purchase
RESP=$(curl -sf -X POST "$URL/api/economy/purchase" \
  -H "Content-Type: application/json" \
  -d "{\"agent_name\":\"$AGENT\",\"item_id\":\"furn_rug\"}" 2>/dev/null)
check_json "POST /economy/purchase" "$RESP" "success"

# ========== AVATAR ==========
echo "── Avatar ──"

# Get avatar
RESP=$(curl -sf "$URL/api/avatar/$AGENT" 2>/dev/null)
check_json "GET /avatar/:name" "$RESP" "color"

# List colors
RESP=$(curl -sf "$URL/api/avatar/colors/list" 2>/dev/null)
check_json "GET /avatar/colors/list" "$RESP" "colors"

# Update avatar
RESP=$(curl -sf -X PUT "$URL/api/avatar/$AGENT" \
  -H "Content-Type: application/json" \
  -d '{"color":"blue"}' 2>/dev/null)
check_json "PUT /avatar/:name (color)" "$RESP" "avatar"

# ========== ROOMS ==========
echo "── Rooms ──"

# Room feed
RESP=$(curl -sf "$URL/api/rooms/by-name/$AGENT/feed?limit=5" 2>/dev/null)
check_json "GET /rooms/by-name/:name/feed" "$RESP" "feed"

# Knocks (should be empty)
RESP=$(curl -sf "$URL/api/rooms/by-name/$AGENT/knocks" 2>/dev/null)
if echo "$RESP" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
  pass "GET /rooms/by-name/:name/knocks"
else
  fail "GET /rooms/by-name/:name/knocks" "invalid json"
fi

# ========== SUMMARY ==========
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━"
TOTAL=$((PASS+FAIL))
echo "  Results: $PASS/$TOTAL passed"
if [ $FAIL -gt 0 ]; then
  echo "  ❌ $FAIL FAILED"
  exit 1
else
  echo "  ✅ All tests passed!"
  exit 0
fi
