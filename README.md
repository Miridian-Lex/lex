# Lex - Meridian Lex Operational Launcher

A project and context management launcher for Claude Code, integrated with the Meridian Lex infrastructure.

## Overview

Lex is the command-line launcher that manages projects, state, and Claude Code sessions within the Meridian ecosystem at `~/meridian-home/`.

## Features

- **Interactive Menu**: Browse and launch projects via TUI
- **Direct Launch**: `lex project-name` to jump directly to a project
- **Project Creation**: Quick scaffolding with `lex --new project-name`
- **State Management**: Track operational mode and focus
- **Project Mapping**: Visualize project relationships

## Installation

### System Version (Stable)

The stable version is installed at `~/.local/bin/lex`.

### Dev Version (Development)

This project contains the development version at `src/lex`. Use `lex-version` to manage which version is active.

## Version Management

Use `src/lex-version` to swap between system and dev versions:

```bash
# Check current version
~/meridian-home/projects/lex/src/lex-version status

# Switch to dev version (symlink - changes take effect immediately)
~/meridian-home/projects/lex/src/lex-version dev

# Switch back to system version (restore from backup)
~/meridian-home/projects/lex/src/lex-version system

# Install dev version as new system version
~/meridian-home/projects/lex/src/lex-version install
```

**Tip**: Add `alias lexv='~/meridian-home/projects/lex/src/lex-version'` to your shell config for quick access.

## Usage

### Basic Commands

```bash
# Interactive menu
lex

# Launch specific project
lex project-name

# Global/home context
lex --global
lex -g

# Create new project
lex --new project-name
lex -n project-name

# List projects
lex --list
lex -l

# Show project map
lex --map
lex -m

# Show state
lex --state
lex -s

# Show version
lex --version
lex -v
```

### Agent OS Integration (v1.1+)

```bash
# Set up Agent OS integration (creates setup-agentos project)
lex --agentos-setup

# Initialize Agent OS in current project
lex --agentos-init

# Initialize with specific profile
lex --agentos-init python

# Initialize in specific project
cd project-name
lex --agentos-init

# Show Agent OS status
lex --agentos-status

# Check status for specific project
lex --agentos-status project-name

# Verify installations
lex --agentos-verify

# Install Agent OS base (if not already installed)
lex --agentos-install-base

# Update Agent OS base
lex --agentos-update
```

**Note**: If Agent OS integration is not available, lex will display a helpful message and offer to set it up via `lex --agentos-setup`.

## Project Structure

```
lex/
├── src/
│   ├── lex              # Main launcher script
│   └── lex-version      # Version management utility
├── tests/
│   └── test-lex.sh      # Test suite
├── docs/
│   └── architecture.md  # Architecture documentation
└── .claude/
    └── CLAUDE.md        # Development guidance
```

## Integration Points

- **Home Base**: `~/meridian-home/`
- **Projects**: `~/meridian-home/projects/`
- **State**: `~/meridian-home/STATE.md`
- **Map**: `~/meridian-home/PROJECT-MAP.md`
- **Config**: `~/meridian-home/LEX-CONFIG.yaml`

## Development

When working on lex:

1. Make changes to `src/lex`
2. Test with `src/lex-version dev` (creates symlink)
3. Changes take effect immediately
4. When stable, use `src/lex-version install` to promote to system version

## Version History

- **v1.2** (2026-02-06): Agent OS setup assistance - offers installation when unavailable
- **v1.1** (2026-02-06): Agent OS integration with full command suite
- **v1.0** (2026-02-06): Initial implementation with interactive menu and basic project management

## Future Enhancements

- Token budget tracking and warnings
- Automated backup and restore
- Project templates and profiles
- Remote session integration
- Auto-initialization of Agent OS on `--new` (configurable)
