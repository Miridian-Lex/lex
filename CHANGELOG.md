# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [2.0.0] - 2026-02-06

### Added
- Modular architecture with hexagonal (ports and adapters) pattern
- Core business logic separated into lex-lib modules
- Flag passing system for Claude Code (--flags, --full-access, --preset, --no-flags)
- Preset system via LEX-CONFIG.yaml for reusable Claude Code configurations
- Conversation management (--continue, --resume-picker, --new-conversation)
- Smart launch with resume menu integration
- Configuration management (--config, --mode, --tokens, --check-auto)
- Task queue tracking (--tasks, TASK-QUEUE.md)
- Project deletion with safety confirmation (-d, --delete)
- Dev mode toggle (--dev-mode) accessible from both system and dev versions
- God mode flag (--god) for global context with full permissions

### Changed
- Upgraded from v1.x monolithic script to v2.0 modular architecture
- Restructured codebase into lib/lex-lib modules: core.sh, projects.sh, config.sh, menu.sh, agentos.sh, conversations.sh
- Menu system now uses color rendering with -e flag (fixes unicode escape display)
- Menu numbering updated to accommodate new options

### Infrastructure
- Moved bash-scripts into lex project as lib directory
- Added Agent OS integration via setup-agentos project
- Agent OS commands installed at .claude/commands/agent-os/ (not tracked in git)
- Agent OS project-specific standards tracked at agent-os/standards/

## [1.2.0] - 2026-02-06

### Added
- Agent OS setup assistance when integration unavailable
- Interactive prompt to create setup-agentos project with placeholder functions
- Comprehensive Agent OS integration flags (--agentos-init, --agentos-status, --agentos-verify, --agentos-install-base, --agentos-update, --agentos-setup)

### Changed
- Agent OS integration now offers guided setup instead of silent failure

## [1.1.0] - 2026-02-06

### Added
- Agent OS integration via lex-integration.sh sourcing
- Dynamic availability detection for Agent OS features
- Conditional menu options based on Agent OS availability

### Infrastructure
- Integration with setup-agentos project for Agent OS functionality

## [1.0.0] - 2026-02-05

### Added
- Initial release of Meridian Lex operational launcher
- Interactive menu system for project navigation
- Project creation with scaffolding (src/, tests/, docs/, .claude/)
- Project listing and selection
- Global/home context launch
- State tracking (STATE.md updates)
- Project map display (PROJECT-MAP.md)
- Git initialization for new projects
- Basic flag support (-h, -l, -g, -n, -m, -s, -v)

### Infrastructure
- System installation at ~/.local/bin/lex
- Dev version at ~/meridian-home/projects/lex/src/lex
- Version management via lex-version utility
- Backup system for safe version switching
