# Claude Token Optimizer

## Overview

A collection of Claude Code slash commands for analyzing and reducing token consumption.

## Repository Structure

```
claude-token-optimizer/
├── commands/           ← Installable slash commands
├── docs/               ← Technique reference and examples
├── templates/          ← Learning log template
└── install.sh          ← Installer script
```

## Commands

| Command | Purpose |
|---------|---------|
| `/token-audit` | Visualize token consumption across config files |
| `/optimize-context` | Compress CLAUDE.md with learning-based feedback |
| `/tool-diet` | Detect unused tool registrations |
| `/prompt-slim` | Compress slash command definition files |
| `/context-guard` | Detect excessive data injection patterns |

## Development

- All commands are standalone `.md` files in `commands/`
- Each command uses YAML frontmatter (`description`, `allowed-tools`, `argument-hint`)
- No external dependencies — pure Claude Code slash commands
- Token estimation: chars × multiplier (0.75 English, 2.3 CJK-mixed, auto-detect)
