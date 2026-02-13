#!/bin/bash
# Lex Configuration Parser
# Purpose: Parse and expose LEX-CONFIG.yaml values for other scripts

set -e

# Configuration file location
CONFIG_FILE="$HOME/meridian-home/lex-internal/config/LEX-CONFIG.yaml"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if yq is available
if ! command -v yq &> /dev/null; then
    echo -e "${RED}Error:${NC} yq is required but not installed" >&2
    exit 1
fi

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}Error:${NC} Configuration file not found: $CONFIG_FILE" >&2
    exit 1
fi

# Function: Get a configuration value
# Usage: lex_config_get "path.to.value"
lex_config_get() {
    local key="$1"
    if [ -z "$key" ]; then
        echo -e "${RED}Error:${NC} No key specified" >&2
        return 1
    fi

    yq ".$key" "$CONFIG_FILE" 2>/dev/null || {
        echo -e "${RED}Error:${NC} Key not found: $key" >&2
        return 1
    }
}

# Function: Set a configuration value
# Usage: lex_config_set "path.to.value" "new value"
# NOTE: This only supports simple key updates like "mode.current"
# Complex nested updates should be done manually in YAML file
lex_config_set() {
    local key="$1"
    local value="$2"

    if [ -z "$key" ] || [ -z "$value" ]; then
        echo -e "${RED}Error:${NC} Key and value required" >&2
        return 1
    fi

    # Create backup
    cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

    # For mode.current specifically, use sed to preserve YAML format
    # (Debian's yq converts to JSON on updates)
    if [ "$key" = "mode.current" ]; then
        sed -i 's/current: ".*"/current: "'"$value"'"/' "$CONFIG_FILE"
        echo -e "${GREEN}[OK]${NC} Updated $key to $value"
    else
        echo -e "${YELLOW}Warning:${NC} Generic key updates not yet implemented" >&2
        echo "Please edit $CONFIG_FILE manually for key: $key" >&2
        return 1
    fi
}

# Function: Get operational mode
lex_config_mode() {
    lex_config_get "mode.current" | tr -d '"'
}

# Function: Get token budget info
lex_config_tokens() {
    # Call lex-budget.sh for real-time token usage tracking
    local budget_script="$HOME/meridian-home/bash-scripts/lex-budget.sh"
    if [ -x "$budget_script" ]; then
        "$budget_script" show
    else
        # Fallback to config-only display if budget script not available
        local daily_limit=$(lex_config_get "token_budget.daily_limit")
        local reserved=$(lex_config_get "token_budget.reserved_for_commander")
        echo "Daily Limit: $daily_limit"
        echo "Reserved: $reserved"
        echo "(Run lex-budget.sh for real-time usage tracking)"
    fi
}

# Function: Get all paths
lex_config_paths() {
    yq '.paths' "$CONFIG_FILE"
}

# Function: Get specific path
lex_config_path() {
    local path_key="$1"
    lex_config_get "paths.$path_key" | tr -d '"'
}

# Function: Check if autonomous mode is enabled
lex_config_autonomous() {
    local enabled=$(lex_config_get "autonomous_mode.enabled")
    if [ "$enabled" = "true" ]; then
        return 0
    else
        return 1
    fi
}

# Function: Display full configuration
lex_config_show() {
    echo -e "${BLUE}=== Meridian Lex Configuration ===${NC}\n"

    echo -e "${GREEN}Operational Mode:${NC}"
    echo " Mode: $(lex_config_get 'mode.current' | tr -d '"')"
    echo " Description: $(lex_config_get 'mode.description' | tr -d '"')"
    echo

    echo -e "${GREEN}Token Budget:${NC}"
    lex_config_tokens
    echo

    echo -e "${GREEN}Autonomous Mode:${NC}"
    echo " Enabled: $(lex_config_get 'autonomous_mode.enabled')"
    echo " Max Daily Tokens: $(lex_config_get 'autonomous_mode.max_daily_tokens')"
    echo " Work Hours: $(lex_config_get 'autonomous_mode.work_hours.start' | tr -d '"') - $(lex_config_get 'autonomous_mode.work_hours.end' | tr -d '"')"
    echo " Pace: $(lex_config_get 'autonomous_mode.work_pace' | tr -d '"')"
    echo

    echo -e "${GREEN}Scheduling:${NC}"
    echo " Enabled: $(lex_config_get 'scheduling.enabled')"
    echo " Check Interval: $(lex_config_get 'scheduling.todo_check_interval')s"
    echo

    echo -e "${GREEN}Metadata:${NC}"
    echo " Vessel ID: $(lex_config_get 'metadata.vessel_id' | tr -d '"')"
    echo " Operator: $(lex_config_get 'metadata.operator' | tr -d '"')"
    echo " Commissioned: $(lex_config_get 'metadata.commissioned' | tr -d '"')"
    echo " Config Version: $(lex_config_get 'metadata.config_version' | tr -d '"')"
}

# Main command dispatcher
case "${1:-}" in
    get)
        lex_config_get "$2"
        ;;
    set)
        lex_config_set "$2" "$3"
        ;;
    mode)
        lex_config_mode
        ;;
    tokens)
        lex_config_tokens
        ;;
    paths)
        if [ -n "$2" ]; then
            lex_config_path "$2"
        else
            lex_config_paths
        fi
        ;;
    autonomous)
        if lex_config_autonomous; then
            echo "Autonomous mode: ENABLED"
            exit 0
        else
            echo "Autonomous mode: DISABLED"
            exit 1
        fi
        ;;
    show|"")
        lex_config_show
        ;;
    help)
        echo "Lex Configuration Utility"
        echo
        echo "Usage:"
        echo " lex-config.sh [command] [arguments]"
        echo
        echo "Commands:"
        echo " show Display full configuration"
        echo " get <key> Get a configuration value (e.g., 'mode.current')"
        echo " set <key> <val> Set a configuration value"
        echo " mode Get current operational mode"
        echo " tokens Display token budget information"
        echo " paths [name] Get all paths or specific path"
        echo " autonomous Check if autonomous mode is enabled"
        echo " help Show this help message"
        echo
        echo "Examples:"
        echo " lex-config.sh mode"
        echo " lex-config.sh get token_budget.daily_limit"
        echo " lex-config.sh paths state_md"
        echo " lex-config.sh set mode.current AUTONOMOUS"
        ;;
    *)
        echo -e "${RED}Error:${NC} Unknown command: $1" >&2
        echo "Run 'lex-config.sh help' for usage information" >&2
        exit 1
        ;;
esac
