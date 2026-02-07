#!/bin/bash
# Lex Projects Library
# Project management functions

list_projects() {
    [ ! -d "$PROJECTS_DIR" ] && { echo "No projects."; return; }
    local projects=($(ls -1 "$PROJECTS_DIR" 2>/dev/null))
    [ ${#projects[@]} -eq 0 ] && { echo -e "${YELLOW}No projects${NC}"; return; }
    echo "Projects:"; echo ""
    for i in "${!projects[@]}"; do echo "  $((i + 1))) ${projects[$i]}"; done
}

select_project() {
    echo ""; list_projects
    local projects=($(ls -1 "$PROJECTS_DIR" 2>/dev/null))
    [ ${#projects[@]} -eq 0 ] && { read -p "Enter..."; show_menu; return; }
    echo ""; read -p "Number (or 'b'): " n
    [[ "$n" == "b" ]] && { show_menu; return; }
    [[ ! "$n" =~ ^[0-9]+$ ]] && { print_error "Invalid"; sleep 1; select_project; return; }
    local i=$((n - 1))
    if [ $i -ge 0 ] && [ $i -lt ${#projects[@]} ]; then
        # Use smart_launch for conversation management
        smart_launch "$PROJECTS_DIR/${projects[$i]}" "${projects[$i]}"
    else
        print_error "Invalid"; sleep 1; select_project
    fi
}

create_project() {
    echo ""; read -p "Name: " name
    [ -z "$name" ] && { print_error "Required"; sleep 1; show_menu; return; }
    local path="$PROJECTS_DIR/$name"
    [ -d "$path" ] && { print_error "Exists"; sleep 1; show_menu; return; }
    mkdir -p "$path"/{src,tests,docs,.claude}
    cd "$path"; git init
    echo "# $name" > README.md
    echo "# Project: $name" > .claude/CLAUDE.md
    touch .gitignore
    print_success "Created"
    read -p "Launch? (y/n): " yn
    [[ "$yn" == "y" ]] && launch_claude "$path" "$name" || show_menu
}

delete_project() {
    echo ""; list_projects
    local projects=($(ls -1 "$PROJECTS_DIR" 2>/dev/null))
    [ ${#projects[@]} -eq 0 ] && { read -p "Enter..."; show_menu; return; }
    echo ""; read -p "Number to delete (or 'b'): " n
    [[ "$n" == "b" ]] && { show_menu; return; }
    [[ ! "$n" =~ ^[0-9]+$ ]] && { print_error "Invalid"; sleep 1; delete_project; return; }
    local i=$((n - 1))
    if [ $i -ge 0 ] && [ $i -lt ${#projects[@]} ]; then
        local project_name="${projects[$i]}"
        local project_path="$PROJECTS_DIR/$project_name"
        echo ""
        print_warn "⚠ DESTRUCTIVE OPERATION ⚠"
        echo ""
        echo -e "  Project: ${RED}$project_name${NC}"
        echo "  Path: $project_path"
        echo ""
        echo "This will permanently delete all files in this project."
        echo ""
        read -p "Type project name to confirm deletion: " confirm
        if [ "$confirm" == "$project_name" ]; then
            rm -rf "$project_path"
            print_success "Deleted: $project_name"
            sleep 1
            show_menu
        else
            print_error "Deletion cancelled (name mismatch)"
            sleep 2
            show_menu
        fi
    else
        print_error "Invalid"; sleep 1; delete_project
    fi
}
