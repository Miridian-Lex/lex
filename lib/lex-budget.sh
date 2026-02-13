#!/bin/bash
# Lex Token Budget Manager
# Integrates Claude Code usage stats with LEX-CONFIG.yaml budget tracking

set -e

# Paths
STATS_FILE="$HOME/.claude/stats-cache.json"
LEX_CONFIG="$HOME/meridian-home/lex-internal/config/LEX-CONFIG.yaml"
LEX_CONFIG_SH="$HOME/meridian-home/bash-scripts/lex-config.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check if stats file exists
if [ ! -f "$STATS_FILE" ]; then
    echo -e "${RED}Error:${NC} Stats cache not found at $STATS_FILE"
    echo "Run Claude Code at least once to generate stats"
    exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo -e "${RED}Error:${NC} jq is required but not installed"
    exit 1
fi

# Get budget limits from config
DAILY_LIMIT=$($LEX_CONFIG_SH get token_budget.daily_limit | tr -d '"')
PER_SESSION_TARGET=$($LEX_CONFIG_SH get token_budget.per_session_target | tr -d '"')
RESERVED=$($LEX_CONFIG_SH get token_budget.reserved_for_commander | tr -d '"')

# Get current usage from stats cache
TODAY=$(date +%Y-%m-%d)

# Extract all-time token usage from modelUsage (it's an object, not array)
TOTAL_INPUT=$(jq '[.modelUsage | to_entries[] |.value.inputTokens] | add // 0' "$STATS_FILE")
TOTAL_OUTPUT=$(jq '[.modelUsage | to_entries[] |.value.outputTokens] | add // 0' "$STATS_FILE")
CACHE_READ=$(jq '[.modelUsage | to_entries[] |.value.cacheReadInputTokens] | add // 0' "$STATS_FILE")
CACHE_CREATE=$(jq '[.modelUsage | to_entries[] |.value.cacheCreationInputTokens] | add // 0' "$STATS_FILE")

# Get today's usage from dailyModelTokens
# Note: tokensByModel contains total tokens (input+output combined) for each model
TODAY_TOTAL=$(jq --arg date "$TODAY" '
    [.dailyModelTokens[] | select(.date == $date) |.tokensByModel | to_entries[] |.value] | add // 0
' "$STATS_FILE")

# Calculate budget metrics
DAILY_REMAINING=$((DAILY_LIMIT - TODAY_TOTAL))
DAILY_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($TODAY_TOTAL / $DAILY_LIMIT) * 100}")

AUTONOMOUS_BUDGET=$((DAILY_LIMIT - RESERVED))
AUTONOMOUS_USED=$TODAY_TOTAL
AUTONOMOUS_REMAINING=$((AUTONOMOUS_BUDGET - AUTONOMOUS_USED))
AUTONOMOUS_PERCENT=$(awk "BEGIN {printf \"%.1f\", ($AUTONOMOUS_USED / $AUTONOMOUS_BUDGET) * 100}")

# Determine status color
if (( $(awk "BEGIN {print ($DAILY_PERCENT >= 90)}") )); then
    STATUS_COLOR=$RED
    STATUS="CRITICAL"
elif (( $(awk "BEGIN {print ($DAILY_PERCENT >= 75)}") )); then
    STATUS_COLOR=$YELLOW
    STATUS="WARNING"
elif (( $(awk "BEGIN {print ($DAILY_PERCENT >= 50)}") )); then
    STATUS_COLOR=$CYAN
    STATUS="MODERATE"
else
    STATUS_COLOR=$GREEN
    STATUS="HEALTHY"
fi

# Display budget status
show_budget() {
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo -e "${BLUE} Lex Token Budget Status${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "${CYAN}Date:${NC} $TODAY"
    echo -e "${CYAN}Status:${NC} ${STATUS_COLOR}${STATUS}${NC} (${DAILY_PERCENT}% of daily limit)"
    echo ""

    echo -e "${GREEN}Daily Budget:${NC}"
    echo " Limit: $(printf '%12s' "$DAILY_LIMIT") tokens"
    echo " Used: $(printf '%12s' "$TODAY_TOTAL") tokens"
    echo " Remaining: $(printf '%12s' "$DAILY_REMAINING") tokens"
    echo ""

    echo -e "${GREEN}Autonomous Budget:${NC}"
    echo " Available: $(printf '%12s' "$AUTONOMOUS_BUDGET") tokens (excludes reserved)"
    echo " Used: $(printf '%12s' "$AUTONOMOUS_USED") tokens"
    echo " Remaining: $(printf '%12s' "$AUTONOMOUS_REMAINING") tokens"
    echo " Reserved: $(printf '%12s' "$RESERVED") tokens (for Commander)"
    echo ""

    echo -e "${GREEN}All-Time Statistics:${NC}"
    echo " Total Input: $(printf '%12s' "$TOTAL_INPUT") tokens"
    echo " Total Output: $(printf '%12s' "$TOTAL_OUTPUT") tokens"
    echo " Cache Read: $(printf '%12s' "$CACHE_READ") tokens"
    echo " Cache Create: $(printf '%12s' "$CACHE_CREATE") tokens"
    echo ""
}

# Show warning if approaching limit
show_warning() {
    if (( $(awk "BEGIN {print ($DAILY_PERCENT >= 75)}") )); then
        echo -e "${YELLOW}[WARNING] WARNING:${NC} Token usage at ${DAILY_PERCENT}% of daily limit"
        echo " Consider pausing autonomous operations"
        echo ""
    fi

    if (( $(awk "BEGIN {print ($AUTONOMOUS_PERCENT >= 90)}") )); then
        echo -e "${YELLOW}[WARNING] WARNING:${NC} Autonomous budget at ${AUTONOMOUS_PERCENT}%"
        echo " ${AUTONOMOUS_REMAINING} tokens remaining for autonomous work"
        echo ""
    fi
}

# Check if over budget
check_budget() {
    if (( TODAY_TOTAL > DAILY_LIMIT )); then
        echo -e "${RED}[FAIL] OVER BUDGET${NC}"
        echo " Used: $TODAY_TOTAL / $DAILY_LIMIT tokens"
        return 1
    elif (( AUTONOMOUS_USED > AUTONOMOUS_BUDGET )); then
        echo -e "${YELLOW}! AUTONOMOUS BUDGET EXCEEDED${NC}"
        echo " Used: $AUTONOMOUS_USED / $AUTONOMOUS_BUDGET tokens"
        echo " Reserved budget for Commander: $RESERVED tokens"
        return 1
    else
        echo -e "${GREEN}[OK] Within budget${NC}"
        return 0
    fi
}

# Show quick summary (for integration in other commands)
show_quick() {
    echo -e "${CYAN}Budget:${NC} $TODAY_TOTAL / $DAILY_LIMIT tokens (${DAILY_PERCENT}%) | ${STATUS_COLOR}${STATUS}${NC}"
}

# Main command dispatcher
case "${1:-show}" in
    show)
        show_budget
        show_warning
        ;;
    check)
        check_budget
        ;;
    quick)
        show_quick
        ;;
    warning)
        show_warning
        ;;
    status)
        echo "$STATUS"
        ;;
    percent)
        echo "$DAILY_PERCENT"
        ;;
    remaining)
        echo "$DAILY_REMAINING"
        ;;
    help)
        echo "Lex Token Budget Manager"
        echo ""
        echo "Usage:"
        echo " lex-budget.sh [command]"
        echo ""
        echo "Commands:"
        echo " show Display full budget status (default)"
        echo " quick Show one-line summary"
        echo " check Check if within budget (exit 0 if yes, 1 if no)"
        echo " warning Show warnings if approaching limit"
        echo " status Get status only (HEALTHY/MODERATE/WARNING/CRITICAL)"
        echo " percent Get usage percentage"
        echo " remaining Get remaining tokens"
        echo " help Show this help"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Run 'lex-budget.sh help' for usage"
        exit 1
        ;;
esac
