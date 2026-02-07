#!/bin/bash
# Lex Menu Library
# Interactive menu system

show_menu() {
    print_header

    # Show current context if in a project
    if [ -n "$LEX_CURRENT_PROJECT" ]; then
        echo -e "${GREEN}Current Context:${NC} $LEX_CURRENT_PROJECT"
        if [ -f "$PWD/.claude/CLAUDE.md" ]; then
            echo -e "${BLUE}Claude Overrides:${NC} Active (.claude/CLAUDE.md present)"
        fi
        echo ""
    fi

    echo "Context:"; echo ""
    echo -e "  ${GREEN}0)${NC} Global (Home)"
    echo -e "  ${GREEN}1)${NC} Select Project"
    echo -e "  ${GREEN}2)${NC} New Project"
    echo -e "  ${GREEN}3)${NC} Delete Project"
    echo ""
    echo "Information:"; echo ""
    echo -e "  ${GREEN}4)${NC} Project Map"
    echo -e "  ${GREEN}5)${NC} State"
    echo -e "  ${GREEN}6)${NC} Task Queue"
    echo ""
    echo "Configuration:"; echo ""
    echo -e "  ${GREEN}7)${NC} Show Config"
    echo -e "  ${GREEN}8)${NC} Operational Mode"
    echo -e "  ${GREEN}9)${NC} Token Budget"
    echo ""
    echo "System:"; echo ""
    echo -e "  ${GREEN}d)${NC} Dev Mode Toggle"

    if [ "$AGENTOS_AVAILABLE" != true ]; then
        echo -e "  ${YELLOW}a)${NC} Setup Agent OS Integration"
    fi

    echo ""
    echo -e "  ${RED}q)${NC} Exit"
    echo ""
    read -p "Choice: " choice

    case $choice in
        0) launch_claude "$LEX_HOME" "Home" ;;
        1) select_project ;;
        2) create_project ;;
        3) delete_project ;;
        4) cat "$PROJECT_MAP"; read -p "Press Enter..."; show_menu ;;
        5) cat "$STATE_FILE"; read -p "Press Enter..."; show_menu ;;
        6) cat "$TASK_QUEUE"; read -p "Press Enter..."; show_menu ;;
        7) show_config ;;
        8) show_mode ;;
        9) show_tokens ;;
        d|D) toggle_dev_mode; read -p "Press Enter..."; show_menu ;;
        a|A)
            if [ "$AGENTOS_AVAILABLE" != true ]; then
                setup_agentos_project
                read -p "Press Enter..."; show_menu
            else
                print_error "Invalid"; sleep 1; show_menu
            fi
            ;;
        q|Q) exit 0 ;;
        *) print_error "Invalid"; sleep 1; show_menu ;;
    esac
}

# Usage/help display
show_usage() {
    echo "Usage: lex [options] [project]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help"
    echo "  -l, --list              List projects"
    echo "  -g, --global            Launch global/home context"
    echo "  -n, --new NAME          Create new project"
    echo "  -d, --delete NAME       Delete project (with confirmation)"
    echo "  -m, --map               Show project map"
    echo "  -s, --state             Show current state"
    echo "  -t, --tasks             Show task queue"
    echo "  -v, --version           Show lex version"
    echo "  --dev-mode              Toggle between dev and system versions"
    echo ""
    echo "Configuration:"
    echo "  --config                Show full configuration"
    echo "  --mode [MODE]           Get or set operational mode"
    echo "  --tokens                Show token budget"
    echo "  --check-auto            Check autonomous mode status"
    echo ""
    echo "Conversation Management:"
    echo "  --continue PROJECT      Continue most recent conversation in project"
    echo "  --resume-picker PROJECT Open conversation selector for project"
    echo "  --new-conversation PROJECT  Start new conversation (skip resume menu)"
    echo ""
    echo "Agent OS Integration:"
    echo "  --agentos-init [PROFILE]    Initialize Agent OS in current/specified project"
    echo "  --agentos-status [PROJECT]  Show Agent OS installation status"
    echo "  --agentos-verify [PROJECT]  Verify Agent OS installations"
    echo "  --agentos-install-base      Install Agent OS base (~/.agent-os/)"
    echo "  --agentos-update            Update Agent OS base installation"
    echo "  --agentos-setup             Set up Agent OS integration (creates setup-agentos project)"
    echo ""
    if [ "$AGENTOS_AVAILABLE" != true ]; then
        echo -e "${YELLOW}Note: Agent OS integration not available${NC}"
        echo "  Missing: $SETUP_AGENTOS_DIR"
        echo "  Run 'lex --agentos-setup' to enable Agent OS features"
        echo ""
    fi
}
