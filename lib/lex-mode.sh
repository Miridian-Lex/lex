#!/bin/bash
# Lex Operational Mode Manager
# Purpose: Sync and manage operational mode between LEX-CONFIG.yaml and STATE.md

set -e

# Source the config utility
LEX_CONFIG="$HOME/meridian-home/bash-scripts/lex-config.sh"
STATE_FILE="$HOME/meridian-home/lex-internal/state/STATE.md"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Valid modes
VALID_MODES=("IDLE" "AUTONOMOUS" "DIRECTED" "COLLABORATIVE")

# Function: Get mode from LEX-CONFIG.yaml
get_config_mode() {
    $LEX_CONFIG mode
}

# Function: Get mode from STATE.md
get_state_mode() {
    grep "^\*\*Mode\*\*:" "$STATE_FILE" | sed 's/.*`\([A-Z]*\)`.*/\1/' | head -1
}

# Function: Validate mode
is_valid_mode() {
    local mode="$1"
    for valid in "${VALID_MODES[@]}"; do
        if [ "$mode" = "$valid" ]; then
            return 0
        fi
    done
    return 1
}

# Function: Set mode in LEX-CONFIG.yaml
set_config_mode() {
    local mode="$1"
    if! is_valid_mode "$mode"; then
        echo -e "${RED}Error:${NC} Invalid mode: $mode" >&2
        echo "Valid modes: ${VALID_MODES[*]}" >&2
        return 1
    fi

    $LEX_CONFIG set mode.current "$mode"
}

# Function: Set mode in STATE.md
set_state_mode() {
    local mode="$1"
    if! is_valid_mode "$mode"; then
        echo -e "${RED}Error:${NC} Invalid mode: $mode" >&2
        return 1
    fi

    # Find the line with **Mode**: and replace it
    # Look for pattern: **Mode**: `SOMETHING`
    sed -i "s/\*\*Mode\*\*: \`[A-Z]*\`/\*\*Mode\*\*: \`$mode\`/" "$STATE_FILE"

    echo -e "${GREEN}[OK]${NC} Updated STATE.md mode to $mode"
}

# Function: Set mode in both locations
set_mode() {
    local mode="$1"
    local description="${2:-Operational mode update}"

    if! is_valid_mode "$mode"; then
        echo -e "${RED}Error:${NC} Invalid mode: $mode" >&2
        echo "Valid modes: ${VALID_MODES[*]}" >&2
        return 1
    fi

    echo -e "${BLUE}Setting operational mode to: $mode${NC}"

    # Update LEX-CONFIG.yaml
    set_config_mode "$mode"

    # Update STATE.md
    set_state_mode "$mode"

    # Update STATE.md timestamp
    local timestamp=$(date -u +"%Y-%m-%d %H:%M UTC")
    sed -i "s/\*\*Last Updated\*\*:.*/\*\*Last Updated\*\*: $timestamp/" "$STATE_FILE"

    echo -e "${GREEN}[OK]${NC} Mode synchronized across LEX-CONFIG.yaml and STATE.md"

    # If mode is AUTONOMOUS, check for lock file
    if [ "$mode" = "AUTONOMOUS" ]; then
        local lock_file="$HOME/meridian-home/lex-internal/state/AUTONOMOUS-MODE.lock"
        if [! -f "$lock_file" ]; then
            echo -e "${YELLOW}!${NC} AUTONOMOUS mode set but no lock file exists"
            echo " Consider creating: $lock_file"
        fi
    fi

    # If mode is IDLE, warn about lock file
    if [ "$mode" = "IDLE" ]; then
        local lock_file="$HOME/meridian-home/lex-internal/state/AUTONOMOUS-MODE.lock"
        if [ -f "$lock_file" ]; then
            echo -e "${YELLOW}!${NC} IDLE mode set but autonomous lock file still exists"
            echo " Consider removing: $lock_file"
        fi
    fi
}

# Function: Check mode sync status
check_sync() {
    local config_mode=$(get_config_mode)
    local state_mode=$(get_state_mode)

    echo -e "${BLUE}=== Mode Sync Status ===${NC}\n"
    echo "LEX-CONFIG.yaml: $config_mode"
    echo "STATE.md: $state_mode"
    echo

    if [ "$config_mode" = "$state_mode" ]; then
        echo -e "${GREEN}[OK] Modes are synchronized${NC}"
        return 0
    else
        echo -e "${YELLOW}! Modes are NOT synchronized${NC}"
        echo
        echo "To sync (use CONFIG as source):"
        echo " lex-mode.sh sync-from-config"
        echo
        echo "To sync (use STATE as source):"
        echo " lex-mode.sh sync-from-state"
        return 1
    fi
}

# Function: Sync from config to state
sync_from_config() {
    local mode=$(get_config_mode)
    echo "Syncing STATE.md to match LEX-CONFIG.yaml ($mode)..."
    set_state_mode "$mode"
}

# Function: Sync from state to config
sync_from_state() {
    local mode=$(get_state_mode)
    echo "Syncing LEX-CONFIG.yaml to match STATE.md ($mode)..."
    set_config_mode "$mode"
}

# Main command dispatcher
case "${1:-}" in
    get)
        echo "Config: $(get_config_mode)"
        echo "State: $(get_state_mode)"
        ;;
    set)
        if [ -z "$2" ]; then
            echo -e "${RED}Error:${NC} Mode required" >&2
            echo "Usage: lex-mode.sh set <MODE> [description]" >&2
            exit 1
        fi
        set_mode "$2" "${3:-}"
        ;;
    check)
        check_sync
        ;;
    sync-from-config)
        sync_from_config
        ;;
    sync-from-state)
        sync_from_state
        ;;
    help|"")
        echo "Lex Operational Mode Manager"
        echo
        echo "Usage:"
        echo " lex-mode.sh [command] [arguments]"
        echo
        echo "Commands:"
        echo " get Get current mode from both sources"
        echo " set <MODE> [desc] Set mode in both CONFIG and STATE"
        echo " check Check if modes are synchronized"
        echo " sync-from-config Sync STATE.md from LEX-CONFIG.yaml"
        echo " sync-from-state Sync LEX-CONFIG.yaml from STATE.md"
        echo " help Show this help message"
        echo
        echo "Valid Modes:"
        echo " IDLE - Awaiting assignment"
        echo " AUTONOMOUS - Working independently"
        echo " DIRECTED - Following specific instructions"
        echo " COLLABORATIVE - Real-time collaboration"
        echo
        echo "Examples:"
        echo " lex-mode.sh get"
        echo " lex-mode.sh set AUTONOMOUS"
        echo " lex-mode.sh check"
        ;;
    *)
        echo -e "${RED}Error:${NC} Unknown command: $1" >&2
        echo "Run 'lex-mode.sh help' for usage information" >&2
        exit 1
        ;;
esac
