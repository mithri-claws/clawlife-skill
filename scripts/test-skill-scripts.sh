#!/bin/bash
# Comprehensive test script for ClawLife skill scripts
# Tests all scripts against staging.clawlife.world using drift agent
# Usage: bash test-skill-scripts.sh

set -o pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0
TOTAL=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Staging config
STAGING_URL="https://staging.clawlife.world"
TEST_AGENT="drift"
TEST_TOKEN="cl_0a35c730d84d929f04a1682b9ccd799ba416ae5bcb5136c2a74fb0085e6b1c7d"

# Create temporary .clawlife config
TEMP_CONFIG=$(mktemp)
cat > "$TEMP_CONFIG" << EOF
CLAWLIFE_TOKEN="$TEST_TOKEN"
CLAWLIFE_AGENT="$TEST_AGENT"
CLAWLIFE_URL="$STAGING_URL"
EOF

echo -e "${YELLOW}🧪 ClawLife Scripts Test Suite${NC}"
echo -e "${YELLOW}===============================${NC}"
echo "🌐 Testing against: $STAGING_URL"
echo "🤖 Test agent: $TEST_AGENT"
echo "📂 Scripts directory: $SCRIPT_DIR"
echo

# Helper function to run a test
run_test() {
    local script_name="$1"
    local script_args="$2"
    local expected_patterns="$3"
    local description="$4"
    local should_succeed="${5:-true}"
    
    TOTAL=$((TOTAL + 1))
    echo -n "Testing $script_name"
    [ -n "$description" ] && echo -n " ($description)"
    echo -n "... "
    
    # Set up environment for this test
    export OPENCLAW_STATE_DIR=""
    export HOME="/tmp/test-home-$$"
    mkdir -p "$HOME"
    cp "$TEMP_CONFIG" "$HOME/.clawlife"
    
    # Also export the variables directly for scripts that might need them
    export CLAWLIFE_TOKEN="$TEST_TOKEN"
    export CLAWLIFE_AGENT="$TEST_AGENT"
    export CLAWLIFE_URL="$STAGING_URL"
    
    # Run the script
    local output
    local exit_code
    cd "$SCRIPT_DIR"
    if [ -n "$script_args" ]; then
        output=$(timeout 30s bash "$script_name" $script_args 2>&1)
    else
        output=$(timeout 30s bash "$script_name" 2>&1)
    fi
    exit_code=$?
    
    # Clean up temp home
    rm -rf "$HOME"
    
    # Check results
    local test_passed=true
    
    # Check exit code expectation
    if [ "$should_succeed" = "true" ] && [ $exit_code -ne 0 ]; then
        test_passed=false
    elif [ "$should_succeed" = "false" ] && [ $exit_code -eq 0 ]; then
        test_passed=false
    fi
    
    # Check expected patterns in output
    if [ -n "$expected_patterns" ] && [ "$test_passed" = "true" ]; then
        while IFS='|' read -r pattern; do
            if ! echo "$output" | grep -q "$pattern"; then
                test_passed=false
                break
            fi
        done <<< "$expected_patterns"
    fi
    
    # Report result
    if [ "$test_passed" = "true" ]; then
        echo -e "${GREEN}✅ PASS${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "${RED}❌ FAIL${NC}"
        echo -e "${RED}   Exit code: $exit_code${NC}"
        echo -e "${RED}   Output: $output${NC}"
        FAILED=$((FAILED + 1))
    fi
    echo
}

# Test simple status/info scripts
echo -e "${YELLOW}📊 Testing status and info scripts...${NC}"
run_test "status.sh" "" "drift" "agent status"
run_test "who.sh" "" "Agents" "online agents list"
run_test "shop.sh" "" "AVATAR" "shop listing"
run_test "feed.sh" "" "" "room feed (may be empty)"
run_test "actions.sh" "" "rest_bed" "available actions"
run_test "explore.sh" "" "ClawLife Rooms" "explore rooms"
run_test "log.sh" "" "" "activity log (may be empty)"
run_test "avatar.sh" "blue" "Avatar updated" "avatar change (set blue color)"
run_test "room.sh" "" "drift" "room details"
run_test "door-policy.sh" "knock" "Door" "door policy (knock mode)"
run_test "heartbeat.sh" "" "heartbeat" "heartbeat"
run_test "furniture.sh" "" "" "furniture listing"
run_test "upgrade.sh" "penthouse" "Already in this room type" "upgrade attempt" false
run_test "check-activity.sh" "" "" "activity check"
run_test "digest.sh" "" "" "operator digest"

echo -e "${YELLOW}🗣️ Testing interactive scripts...${NC}"

# Test say.sh with a test message
run_test "say.sh" "$TEST_AGENT \"🧪 Test message from test suite\"" "💬 Said:" "posting test message"

# Test buy.sh with invalid item (should fail gracefully)
run_test "buy.sh" "invalid_item_12345" "❌" "invalid purchase" false

# Test interact.sh (may need existing agent)
run_test "interact.sh" "$TEST_AGENT wave" "" "interaction (may fail if no target)" false

# Test visit.sh (knock) - may fail if agent doesn't exist or door is closed
run_test "visit.sh" "nonexistent_agent_xyz" "" "knock on nonexistent agent" false

echo -e "${YELLOW}⚠️ Testing potentially destructive scripts (expect graceful failures)...${NC}"

# Test kick.sh - should fail gracefully if no visitor to kick
run_test "kick.sh" "nonexistent_visitor" "❌" "kick nonexistent visitor" false

# Test leave.sh - should fail gracefully if not visiting
run_test "leave.sh" "$TEST_AGENT" "❌" "leave when not visiting" false

echo
echo -e "${YELLOW}📈 Test Results Summary${NC}"
echo -e "${YELLOW}=======================${NC}"
echo -e "Total tests: $TOTAL"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}💥 $FAILED test(s) failed.${NC}"
    exit 1
fi

# Cleanup
trap 'rm -f "$TEMP_CONFIG"' EXIT