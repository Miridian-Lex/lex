#!/bin/bash
# Lex Core Library
# Shared utilities and functions

# Colors
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export YELLOW='\033[1;33m'
export NC='\033[0m'

# Paths
export LEX_HOME="/home/meridian/meridian-home"
export LEX_INTERNAL="$LEX_HOME/lex-internal"
export PROJECTS_DIR="$LEX_HOME/projects"
export STATE_FILE="$LEX_INTERNAL/state/STATE.md"
export PROJECT_MAP="$LEX_INTERNAL/state/PROJECT-MAP.md"
export TASK_QUEUE="$LEX_INTERNAL/state/TASK-QUEUE.md"
export LEX_CONFIG="$LEX_INTERNAL/config/LEX-CONFIG.yaml"
export SETUP_AGENTOS_DIR="$LEX_HOME/projects/setup-agentos"

# Utilities
export LEX_CONFIG_SH="$LEX_HOME/projects/lex/lib/lex-config.sh"
export LEX_MODE_SH="$LEX_HOME/projects/lex/lib/lex-mode.sh"
export CHECK_AUTO_SH="$LEX_HOME/bash-scripts/check-autonomous-mode.sh"

# Print utilities
print_header() {
    echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
    echo -e "${CYAN} MERIDIAN LEX - Operational Launcher${NC}"
    echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
    echo ""
}

print_success() { echo -e "${GREEN}[OK]${NC} $1"; }
print_error() { echo -e "${RED}[FAIL]${NC} $1"; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

# State management
update_state() {
    local mode=$1
    local focus=$2
    local timestamp=$(date -u +"%Y-%m-%d %H:%M UTC")
    sed -i "s/^**Last Updated**:.*/\*\*Last Updated\*\*: $timestamp/" "$STATE_FILE" 2>/dev/null || true
}

# Lex invocation logger
log_lex_action() {
    local action="$1"
    local details="${2:-}"
    local log_file="$LEX_HOME/logs/lex-invocations.log"
    local timestamp=$(date -u +"%Y-%m-%d %H:%M:%S UTC")

    # Ensure log directory exists
    mkdir -p "$LEX_HOME/logs"

    # Log entry
    echo "[$timestamp] $action | $details" >> "$log_file"
}

# Get claude flags from config or environment
get_claude_flags() {
    # Priority: LEX_CLAUDE_FLAGS env var > config defaults
    if [ -n "$LEX_CLAUDE_FLAGS" ]; then
        echo "$LEX_CLAUDE_FLAGS"
    else
        # Get default flags from config
        local config_flags=$($LEX_CONFIG_SH get claude.default_flags 2>/dev/null | tr -d '"')
        echo "$config_flags"
    fi
}

# Claude launcher
launch_claude() {
    local flags=$(get_claude_flags)
    cd "$1"
    update_state "DIRECTED" "$2"
    log_lex_action "LAUNCH" "$2 (new conversation) | flags=$flags | pwd=$1"
    print_info "Launching: $2"
    [ -n "$flags" ] && print_info "Flags: $flags"
    exec claude $flags
}
