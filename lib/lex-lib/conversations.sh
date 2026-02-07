#!/bin/bash
# Lex Conversations Library
# Conversation history and resume management
# Uses Claude Code's native conversation persistence features
# NOTE: get_claude_flags() defined in core.sh

# Launch Claude with conversation resume
# Uses Claude Code's --continue flag to resume most recent conversation
launch_claude_continue() {
    local project_path="$1"
    local project_name="$2"
    local flags=$(get_claude_flags)

    cd "$project_path"
    update_state "DIRECTED" "$project_name (continuing)"
    log_lex_action "CONTINUE" "$project_name | flags=$flags | pwd=$project_path"
    print_info "Resuming most recent conversation: $project_name"
    [ -n "$flags" ] && print_info "Flags: $flags"
    exec claude --continue $flags
}

# Launch Claude with interactive conversation picker
# Uses Claude Code's --resume flag with no argument for picker
launch_claude_resume_picker() {
    local project_path="$1"
    local project_name="$2"
    local flags=$(get_claude_flags)

    cd "$project_path"
    update_state "DIRECTED" "$project_name (selecting conversation)"
    log_lex_action "RESUME_PICKER" "$project_name | flags=$flags | pwd=$project_path"
    print_info "Opening conversation selector: $project_name"
    [ -n "$flags" ] && print_info "Flags: $flags"
    exec claude --resume $flags
}

# Launch Claude resuming specific session ID
launch_claude_resume_id() {
    local project_path="$1"
    local project_name="$2"
    local session_id="$3"
    local flags=$(get_claude_flags)

    cd "$project_path"
    update_state "DIRECTED" "$project_name (resume: ${session_id:0:8}...)"
    log_lex_action "RESUME_ID" "$project_name | session=$session_id | flags=$flags | pwd=$project_path"
    print_info "Resuming session $session_id in: $project_name"
    [ -n "$flags" ] && print_info "Flags: $flags"
    exec claude --resume "$session_id" $flags
}

# Launch Claude with new conversation (explicit)
launch_claude_new() {
    local project_path="$1"
    local project_name="$2"
    local flags=$(get_claude_flags)

    cd "$project_path"
    update_state "DIRECTED" "$project_name (new conversation)"
    log_lex_action "NEW_CONVERSATION" "$project_name | flags=$flags | pwd=$project_path"
    print_info "Starting new conversation: $project_name"
    [ -n "$flags" ] && print_info "Flags: $flags"
    # No --continue or --resume = new conversation
    exec claude $flags
}

# Interactive conversation launch menu
conversation_launch_menu() {
    local project_path="$1"
    local project_name="$2"

    echo ""
    echo -e "${CYAN}═══ Launch: $project_name ═══${NC}"
    echo ""
    echo "Options:"
    echo "  1) Continue most recent conversation"
    echo "  2) Select from conversation history (interactive picker)"
    echo "  3) Start new conversation"
    echo "  4) Resume specific session ID"
    echo "  b) Back to menu"
    echo ""
    read -p "Choice: " choice

    case $choice in
        1) launch_claude_continue "$project_path" "$project_name" ;;
        2) launch_claude_resume_picker "$project_path" "$project_name" ;;
        3) launch_claude_new "$project_path" "$project_name" ;;
        4)
            echo ""
            read -p "Enter session ID: " session_id
            if [ -n "$session_id" ]; then
                launch_claude_resume_id "$project_path" "$project_name" "$session_id"
            else
                print_error "Session ID required"
                sleep 1
                conversation_launch_menu "$project_path" "$project_name"
            fi
            ;;
        b|B) show_menu ;;
        *) print_error "Invalid"; sleep 1; conversation_launch_menu "$project_path" "$project_name" ;;
    esac
}

# Smart launch - shows conversation menu if project has history
# Otherwise launches directly
smart_launch() {
    local project_path="$1"
    local project_name="$2"
    local force_new="${3:-false}"

    # If force_new, skip menu and start new conversation
    if [ "$force_new" = "true" ]; then
        launch_claude_new "$project_path" "$project_name"
        return
    fi

    # Check if .claude directory exists (indicator of previous sessions)
    if [ -d "$project_path/.claude" ]; then
        # Project has been used with Claude before
        # Show conversation options
        conversation_launch_menu "$project_path" "$project_name"
    else
        # New project, launch directly
        launch_claude "$project_path" "$project_name"
    fi
}
