# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Lex** is the operational launcher for Meridian Lex - a command-line tool that manages Claude Code projects, contexts, and sessions within the `~/meridian-home/` infrastructure.

**Language**: Bash shell script
**Current Version**: 1.0

## Architecture

### Core Script (`src/lex`)

Single-file bash script with:
- **Interactive menu system**: TUI for project browsing
- **Direct launch**: Command-line arguments for quick access
- **Project management**: Creation, listing, and navigation
- **State tracking**: Updates `STATE.md` on launches
- **Color-coded output**: ANSI color codes for visual clarity

### Version Management (`src/lex-version`)

Utility for swapping between versions:
- **System version**: Stable, at `~/.local/bin/lex`
- **Dev version**: Development, at `src/lex`
- **Backup**: `~/.local/bin/lex.system-backup`

**Modes**:
- `dev`: Symlink system to dev (live changes)
- `system`: Restore from backup
- `install`: Promote dev to system (new stable)

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

### State Management

The `update_state()` function modifies `STATE.md`:
```bash
update_state "DIRECTED" "project-name"
```

Updates the timestamp in STATE.md to track activity.

## Command Structure

### Flags and Options

Current flags:
- `-h, --help` - Show usage
- `-l, --list` - List projects
- `-g, --global` - Launch in global context
- `-n, --new NAME` - Create new project
- `-m, --map` - Show project map
- `-s, --state` - Show current state

### Future Flags (Planned)

Agent OS integration:
- `--agentos-init [project]` - Initialize Agent OS
- `--agentos-verify` - Verify installations
- `--agentos-update` - Update base Agent OS
- `--agentos-profile PROFILE` - Set project profile

Version management:
- `--version` - Show lex version
- `--upgrade` - Update lex from repo/source

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
```

### Automated Testing (Future)
Create `tests/test-lex.sh` for:
- Project creation/deletion
- State updates
- Error handling
- Flag parsing

## Future Development

### Phase 1: Agent OS Integration
- Add `--agentos-*` flags
- Read config from `LEX-CONFIG.yaml`
- Auto-initialize Agent OS on `--new`
- Integrate with `setup-agentos` project

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
    # ... existing cases ...
    --new-flag|-nf)
        handle_new_flag "$@"
        ;;
esac

# In usage() function:
echo "  --new-flag, -nf  Description"
```

### Modify Interactive Menu
Edit `show_menu()` function:
```bash
echo "  ${GREEN}5)${NC} New Option"

# In case statement:
5) handle_new_option ;;
```

## Git Workflow

- **Branch naming**: `feature/description` or `fix/description`
- **Commit format**: Conventional commits
- **Co-authored by**: Include `Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>`
- **Testing**: Always test in dev mode before committing

## Dependencies

- **Bash**: 4.0+ (uses arrays)
- **Git**: For project initialization
- **Claude Code**: Target integration
- **sed**: For state file updates
- **readlink**: For symlink resolution (in lex-version)

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
