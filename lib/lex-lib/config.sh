#!/bin/bash
# Lex Configuration Library
# Configuration and mode management functions

# Show configuration
show_config() {
    $LEX_CONFIG_SH show
    echo ""
    read -p "Press Enter to continue..."
    show_menu
}

# Show operational mode status
show_mode() {
    echo ""
    echo -e "${CYAN}═══ Operational Mode Status ═══${NC}"
    echo ""
    $LEX_MODE_SH check
    echo ""
    echo "Options:"
    echo "  1) Set mode to IDLE"
    echo "  2) Set mode to AUTONOMOUS"
    echo "  3) Set mode to DIRECTED"
    echo "  4) Set mode to COLLABORATIVE"
    echo "  5) Check autonomous mode status"
    echo "  b) Back to menu"
    echo ""
    read -p "Choice: " choice

    case $choice in
        1) $LEX_MODE_SH set IDLE && sleep 2 ;;
        2) $LEX_MODE_SH set AUTONOMOUS && sleep 2 ;;
        3) $LEX_MODE_SH set DIRECTED && sleep 2 ;;
        4) $LEX_MODE_SH set COLLABORATIVE && sleep 2 ;;
        5) $CHECK_AUTO_SH; read -p "Press Enter..." ;;
        b|B) ;;
        *) print_error "Invalid"; sleep 1 ;;
    esac
    show_menu
}

# Show token budget
show_tokens() {
    echo ""
    echo -e "${CYAN}═══ Token Budget ═══${NC}"
    echo ""
    $LEX_CONFIG_SH tokens
    echo ""
    read -p "Press Enter to continue..."
    show_menu
}

# Toggle dev mode
toggle_dev_mode() {
    local system_lex="$HOME/.local/bin/lex"
    local dev_lex="$HOME/meridian-home/projects/lex/src/lex"
    local backup_lex="$HOME/.local/bin/lex.system-backup"

    # Check current version state
    if [ -L "$system_lex" ]; then
        local target=$(readlink -f "$system_lex")
        if [ "$target" == "$dev_lex" ]; then
            # Currently in dev mode, switch to system
            echo ""
            print_info "Current mode: DEV (symlink active)"
            echo ""
            if [ ! -f "$backup_lex" ]; then
                print_error "Cannot restore: system backup not found"
                return 1
            fi
            read -p "Switch to SYSTEM mode? (y/n): " yn
            if [[ "$yn" == "y" ]]; then
                rm "$system_lex"
                cp "$backup_lex" "$system_lex"
                chmod +x "$system_lex"
                print_success "Switched to SYSTEM mode"
                print_warn "Restart lex for changes to take effect"
            else
                print_info "Cancelled"
            fi
        else
            print_warn "Unknown symlink state"
            echo "  Target: $target"
            echo "  Expected: $dev_lex"
        fi
    elif [ -f "$system_lex" ]; then
        # Currently in system mode, switch to dev
        echo ""
        print_info "Current mode: SYSTEM (stable)"
        echo ""
        if [ ! -f "$dev_lex" ]; then
            print_error "Dev version not found: $dev_lex"
            return 1
        fi
        read -p "Switch to DEV mode? (y/n): " yn
        if [[ "$yn" == "y" ]]; then
            cp "$system_lex" "$backup_lex"
            rm "$system_lex"
            ln -s "$dev_lex" "$system_lex"
            print_success "Switched to DEV mode"
            print_warn "Changes to $dev_lex take effect immediately"
            print_info "Run 'lex --dev-mode' to switch back"
        else
            print_info "Cancelled"
        fi
    else
        print_error "Lex not installed at $system_lex"
    fi
}
