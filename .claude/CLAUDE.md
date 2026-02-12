# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Lex** is the operational launcher for Meridian Lex - a command-line tool that manages Claude Code projects, contexts, and sessions within the `~/meridian-home/` infrastructure.

**Language**: Bash shell script
**Current Version**: 1.2

## Architecture

### Execution Flow

When `lex` is invoked, the following happens:

1. **Initialization**:
   - Sets `set -e` for fail-fast behavior
   - Defines color constants and utility functions
   - Attempts to source Agent OS integration from `setup-agentos/src/lex-integration.sh`
   - Sets `AGENTOS_AVAILABLE` flag based on source success

2. **Command routing**:
   - No args → Interactive menu (`show_menu()`)
   - Flag → Execute corresponding function
   - Project name → Launch Claude Code in that project (`launch_claude()`)

3. **Session launch**:
   - Changes to target directory
   - Updates `STATE.md` with mode and project name
   - Executes `claude` (replaces current process with `exec`)

4. **Agent OS delegation**:
   - All `--agentos-*` commands check `AGENTOS_AVAILABLE` flag
   - If unavailable, print error and exit
   - If available, delegate to sourced functions from `lex-integration.sh`

### Core Script (`src/lex`)

Single-file bash script with:
- **Interactive menu system**: TUI for project browsing
- **Direct launch**: Command-line arguments for quick access
- **Project management**: Creation, listing, and navigation
- **State tracking**: Updates `STATE.md` on launches
- **Color-coded output**: ANSI color codes for visual clarity
- **Agent OS integration**: Dynamically sources integration functions from `setup-agentos` project

### Version Management (`src/lex-version`)

Utility for swapping between versions:
- **System version**: Stable, at `~/.local/bin/lex`
- **Dev version**: Development, at `src/lex`
- **Backup**: `~/.local/bin/lex.system-backup`

**Version States** (detected by `check_version()`):
- `system` - Regular file at `~/.local/bin/lex` (stable)
- `dev` - Symlink pointing to `src/lex` (development mode)
- `none` - No installation found
- `unknown-link` - Symlink pointing elsewhere (unexpected state)

**Operations**:
- `dev` - Backs up system version, creates symlink to `src/lex` (changes take effect immediately)
- `system` - Removes symlink, restores from backup (requires backup to exist)
- `install` - Copies dev to system as regular file (promotes to stable, not a symlink)
- `status` - Shows current state, paths, and backup availability

**Safety**: Always backs up before destructive operations; uses `readlink -f` for canonical path resolution.

## Development Workflow

1. **Make changes** to `src/lex`
2. **Switch to dev**: `src/lex-version dev`
3. **Test** using `lex` commands (symlink active)
4. **Iterate** - changes take effect immediately
5. **Promote to stable**: `src/lex-version install` when ready
6. **Commit** with conventional commit messages

## Key Integration Points

### File System Locations
- `~/meridian-home/` - Home base
- `~/meridian-home/projects/` - Project directory
- `~/meridian-home/STATE.md` - Operational state
- `~/meridian-home/PROJECT-MAP.md` - Project relationships
- `~/meridian-home/LEX-CONFIG.yaml` - Configuration (future)
- `~/.local/bin/lex` - System installation
- `~/meridian-home/projects/setup-agentos/src/lex-integration.sh` - Agent OS integration functions (sourced at runtime)

### State Management

The `update_state()` function modifies `STATE.md`:
```bash
update_state "DIRECTED" "project-name"
```

Updates the timestamp in STATE.md to track activity. Uses `sed -i` for in-place updates with `|| true` to prevent failures if STATE.md doesn't exist.

### Agent OS Integration

Lex dynamically integrates with the `setup-agentos` project:

1. **Runtime loading**: Sources `lex-integration.sh` if present in `~/meridian-home/projects/setup-agentos/src/`
2. **Availability check**: Sets `AGENTOS_AVAILABLE` flag (true/false) based on whether integration functions loaded
3. **Conditional features**: Agent OS commands only available when `AGENTOS_AVAILABLE=true`
4. **Function delegation**: All Agent OS operations delegated to sourced functions (e.g., `agentos_init_current_project`, `agentos_status`, `agentos_verify`)
5. **Setup assistance** (v1.2+): When unavailable, lex offers to create the `setup-agentos` project with placeholder functions

This design allows lex to operate without Agent OS while gracefully enabling features when available. The `setup_agentos_project()` function creates a basic project structure with placeholder integration functions when the setup-agentos project is missing.

### Interactive Menu System

The TUI (`show_menu()`) provides numbered options:
- **Option 0**: Global/home context (`~/meridian-home/`)
- **Option 1**: Project selection (calls `select_project()`)
- **Option 2**: New project creation (calls `create_project()`)
- **Option 3**: Display project map (reads `PROJECT-MAP.md`)
- **Option 4**: Display state (reads `STATE.md`)
- **Option q**: Exit

Menu navigation is recursive - invalid choices loop back to menu after brief error display.

### Project Scaffolding

When creating new projects (via `-n` flag or menu option 2), lex creates:
```
project-name/
├── src/ # Source code
├── tests/ # Test files
├── docs/ # Documentation
├──.claude/ # Claude Code configuration
│ └── CLAUDE.md # Project-specific instructions
├── README.md # Project README
└──.gitignore # Git ignore patterns (empty initially)
```

Git is initialized automatically. User is prompted whether to launch Claude Code immediately after creation.

## Command Structure

### Flags and Options

**Core flags:**
- `-h, --help` - Show usage
- `-v, --version` - Show lex version
- `-l, --list` - List projects
- `-g, --global` - Launch in global context
- `-n, --new NAME` - Create new project
- `-m, --map` - Show project map
- `-s, --state` - Show current state

**Agent OS integration:**
- `--agentos-setup` - Set up Agent OS integration (creates setup-agentos project with placeholders)
- `--agentos-init [PROFILE]` - Initialize Agent OS in current project (or specify profile)
- `--agentos-status [PROJECT]` - Show Agent OS installation status for project
- `--agentos-verify [PROJECT]` - Verify Agent OS installations
- `--agentos-install-base` - Install Agent OS base at `~/.agent-os/`
- `--agentos-update` - Update Agent OS base installation

**Note**: When Agent OS integration is unavailable, lex displays helpful guidance and suggests running `--agentos-setup`.

**Future flags (planned):**
- `--upgrade` - Update lex from repo/source
- Profile templates for `--new` command

## Code Style

### Bash Conventions
- Use `snake_case` for functions and variables
- Color constants in UPPERCASE (`RED`, `GREEN`, etc.)
- Always use `set -e` for error handling
- Quote variables: `"$var"` not `$var`
- Local variables in functions: `local var=value`

### Function Naming
- `print_*()` - Output functions (success, error, info)
- `*_project()` - Project operations
- `show_*()` - Display functions
- `update_*()` - State modification

### Error Handling
- Check prerequisites before operations
- Provide clear error messages with `print_error`
- Exit with non-zero on failures
- Use `|| true` for non-critical operations

## Testing

### Manual Testing
```bash
# Switch to dev version
src/lex-version dev

# Test interactive menu
lex

# Test direct launch
lex setup-agentos

# Test project creation
lex -n test-project

# Test flags
lex -l
lex -m
lex -s
lex -v

# Test Agent OS integration (if setup-agentos available)
cd ~/meridian-home/projects/some-project
lex --agentos-init
lex --agentos-status
lex --agentos-verify
```

### Automated Testing (Future)
Create `tests/test-lex.sh` for:
- Project creation/deletion
- State updates
- Error handling
- Flag parsing
- Agent OS integration availability detection

## Future Development

### Phase 1: Agent OS Integration [OK] COMPLETED (v1.2)
- [OK] Add `--agentos-*` flags (v1.1)
- [OK] Integrate with `setup-agentos` project (v1.1)
- [OK] Offer setup assistance when unavailable (v1.2)
- Read config from `LEX-CONFIG.yaml` (pending)
- Auto-initialize Agent OS on `--new` (pending)

### Phase 2: Enhanced Features
- Token budget tracking and warnings
- Project templates/profiles
- Config file support (`LEX-CONFIG.yaml`)
- Version checking and auto-updates

### Phase 3: Advanced Operations
- Remote session integration
- Multi-project operations
- Backup and restore
- Project archiving

## Adding New Features

When adding new functionality:

1. **Update version** in script header
2. **Add flag** to `usage()` and `main()` case statement
3. **Implement function** following naming conventions
4. **Update README.md** with new usage
5. **Test in dev mode** before promoting
6. **Document** in this CLAUDE.md

## Common Operations

### Increment Version
```bash
# In src/lex, update:
# Version: 1.0 → Version: 1.1
```

### Add New Flag
```bash
# In main() function:
case "$1" in
    #... existing cases...
    --new-flag|-nf)
        handle_new_flag "$@"
        ;;
esac

# In usage() function:
echo " --new-flag, -nf Description"
```

### Modify Interactive Menu
Edit `show_menu()` function:
```bash
echo " ${GREEN}5)${NC} New Option"

# In case statement:
5) handle_new_option;;
```

## Git Workflow

- **Branch naming**: `feature/description` or `fix/description`
- **Commit format**: Conventional commits
- **Co-authored by**: Include `Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>`
- **Testing**: Always test in dev mode before committing

## Dependencies

**Required:**
- **Bash**: 4.0+ (uses arrays)
- **Git**: For project initialization
- **Claude Code**: Target integration (`exec claude` for launching sessions)
- **sed**: For state file updates (with `-i` flag)
- **readlink**: For symlink resolution in `lex-version` (with `-f` flag for canonical path)

**Optional:**
- **setup-agentos project**: For Agent OS integration features (`~/meridian-home/projects/setup-agentos/src/lex-integration.sh`)

## Security Considerations

- No credential handling (uses separate `secrets.yaml`)
- No remote execution
- File operations limited to `~/meridian-home/projects/`
- Backup before destructive operations

## Notes for Future Maintainers

- Keep script self-contained (single file preferred)
- Maintain backward compatibility with existing projects
- Document breaking changes clearly
- Test on Debian 12 (target system)
- Consider `lex-version` workflow when making changes
