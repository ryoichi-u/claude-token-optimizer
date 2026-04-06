# Claude Token Optimizer

A set of [Claude Code](https://docs.anthropic.com/en/docs/claude-code) slash commands for analyzing and reducing token consumption in your projects.

Token usage in Claude Code comes from multiple sources: `CLAUDE.md` context files, slash command definitions, agent definitions, tool registrations, and runtime data injection. This toolkit helps you identify and reduce waste across all of these.

## Quick Start

```bash
git clone https://github.com/ryoichi-u/claude-token-optimizer.git
cd claude-token-optimizer
./install.sh --target ~/your-project
```

Then in Claude Code:

```
/token-audit          # See where your tokens go
/optimize-context     # Compress CLAUDE.md files
/tool-diet            # Remove unused tool definitions
/prompt-slim          # Slim down command files
/context-guard        # Find runtime data injection risks
```

## Commands

### `/token-audit` — Visualize Token Consumption

Scans all `CLAUDE.md`, `.claude/commands/`, and `.claude/agents/` files. Outputs a table showing estimated token consumption by category, with section-level breakdown for the largest files.

```
/token-audit            # Current directory
/token-audit --all      # Full project scan
```

### `/optimize-context` — Compress CLAUDE.md

Applies 7 compression techniques (deduplication, table compression, section extraction, etc.) to reduce CLAUDE.md size while preserving all information. Tracks results in a learning log to improve over time.

```
/optimize-context               # Root CLAUDE.md
/optimize-context my-agent      # Specific subdirectory
/optimize-context --all         # All CLAUDE.md files
/optimize-context --dry-run     # Preview only
```

**Real-world result**: 348 lines → 113 lines (66% reduction) on a production monorepo.

### `/tool-diet` — Remove Unused Tools

Cross-references registered tool permissions (`settings.local.json`) with actual usage in commands and CLAUDE.md files. Each unused tool wastes ~200 tokens per session.

```
/tool-diet              # Analyze and suggest
/tool-diet --dry-run    # Report only
```

### `/prompt-slim` — Compress Command Files

Slash command `.md` files are loaded into context every time they're invoked. This command finds compression opportunities (verbose preambles, redundant examples, etc.) without changing behavior.

```
/prompt-slim                # All commands
/prompt-slim deploy         # Specific command
/prompt-slim --dry-run      # Preview only
```

### `/context-guard` — Detect Data Injection Risks

Scans commands and CLAUDE.md for patterns that can cause excessive runtime token consumption: unbounded file reads, full-collection loops, raw data injection without filtering, etc.

```
/context-guard          # Scan all files
```

## Installation

### Option 1: Install Script

```bash
./install.sh --all --target ~/your-project    # Install all commands
./install.sh --pick --target ~/your-project   # Choose which to install
./install.sh --list                           # See available commands
```

### Option 2: Manual Copy

Copy any `.md` files from `commands/` to your project's `.claude/commands/`:

```bash
cp commands/token-audit.md ~/your-project/.claude/commands/
```

## Token Estimation

Since Claude Code doesn't expose exact token counts, we use character-based estimation:

| Content Type | Multiplier | Basis |
|-------------|-----------|-------|
| English text | ×0.75 | ~4 chars/token average |
| CJK-mixed text | ×2.3 | Multi-byte encoding overhead |
| Tool definitions | ~200/tool | Empirical average |

Language is auto-detected per file based on multi-byte character ratio.

## Techniques Reference

See [docs/techniques.md](docs/techniques.md) for the full catalog of optimization techniques, including:

- **Static**: CLAUDE.md compression (7 techniques)
- **Runtime**: Pre-filtering, phased execution, sampling, model selection
- **Tools**: Unused tool removal, MCP server selection

## Before & After Example

See [docs/examples/claude-md-before-after.md](docs/examples/claude-md-before-after.md) for a detailed walkthrough of a 66% reduction.

## FAQ

**Q: Will compression break my project?**
A: The tools never delete information — they move, compress, or simplify. `/optimize-context` always asks for confirmation before making changes, and you can `git checkout` to revert.

**Q: How accurate are the token estimates?**
A: They're approximations. The actual Claude tokenizer may differ, but the relative comparisons (which files are largest, how much a change reduces) are reliable for optimization decisions.

**Q: Do I need all 5 commands?**
A: No. Start with `/token-audit` to see your baseline, then add others as needed. Each command is independent.

## License

MIT
