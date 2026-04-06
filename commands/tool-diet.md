---
description: Detect unused or redundant tool definitions and estimate token savings
allowed-tools: Read, Glob, Grep, Bash(wc*), Bash(jq*)
argument-hint: "[--dry-run]"
---

# Tool Diet

Args: $ARGUMENTS

## Overview

Analyze registered tools and MCP server definitions to find unused or redundant entries.
Each tool definition consumes approximately 150-300 tokens of context window space.
Removing unused tools directly reduces per-session token consumption.

## Step 1: Inventory Tool Registrations

### 1.1 Settings Permissions

Read `.claude/settings.local.json` (if exists). Extract entries from:
- `permissions.allow` — each entry is a tool available to Claude
- Count total entries and categorize:
  - `Bash(...)` patterns
  - `Read`, `Write`, `Edit`, `Glob`, `Grep` (built-in)
  - `mcp__*` (MCP server tools)
  - Other

### 1.2 MCP Server Definitions

Read `.mcp.json` (if exists). Count:
- Number of MCP servers defined
- Estimated tools per server (if tool list is available in config)

### 1.3 Estimate Token Consumption

```
Estimated tokens = number_of_tools × 200  (conservative average)
```

## Step 2: Analyze Actual Usage

### 2.1 Command-Level Usage

Scan all `.claude/commands/*.md` files. For each file:
1. Read `allowed-tools` from frontmatter
2. Collect the set of tools referenced

Build a union set of all tools referenced across commands.

### 2.2 CLAUDE.md References

Scan all `CLAUDE.md` and `**/CLAUDE.md` files for tool name mentions
(e.g., `Bash`, `Read`, `mcp__slack__*`).

### 2.3 Agent Definition Usage

Scan `.claude/agents/*.md` for `tools:` frontmatter fields.

## Step 3: Cross-Reference

Compare:
- **Registered** (Step 1) vs **Referenced** (Step 2)
- Flag tools that are registered but never referenced in any command, agent, or CLAUDE.md

Categorize results:

| Status | Meaning |
|--------|---------|
| **Active** | Referenced in at least one command/agent |
| **Implicit** | Built-in tools (Read, Write, etc.) — always available, no action needed |
| **Unused** | Registered but not referenced anywhere |
| **One-time** | Only in `Bash(...)` patterns that look temporary (e.g., `Bash(kill 4487:*)`) |

## Step 4: Output Report

```markdown
## Tool Diet Report

Scan date: YYYY-MM-DD

### Summary

| Category | Count | Est. Tokens |
|----------|-------|-------------|
| Active tools | 35 | ~7,000 |
| Unused tools | 8 | ~1,600 |
| One-time/temp | 3 | ~600 |
| **Total registered** | **46** | **~9,200** |

### Unused Tools (candidates for removal)

| Tool | Type | Last Seen In |
|------|------|-------------|
| Bash(xxd:*) | Bash pattern | Not found |
| mcp__drive__search | MCP | Not found |
| ... | ... | ... |

### One-Time Patterns (likely temporary)

| Tool | Pattern |
|------|---------|
| Bash(kill 4487:*) | Process-specific, likely debug |
| ... | ... |

### Potential Savings

Removing {N} unused + {M} one-time tools:
- Estimated reduction: ~{K} tokens per session
- Action: Remove entries from `.claude/settings.local.json` → `permissions.allow`
```

## Step 5: Guided Cleanup (if not --dry-run)

If user approves:
1. Show the specific entries to remove from `settings.local.json`
2. Ask for confirmation
3. Edit the file to remove unused entries
4. Report final tool count and estimated savings

If `--dry-run`: Display report only, no changes.

## Notes

- This skill does NOT remove MCP servers — only permission entries
- Some tools may be used interactively (not in commands) — the "unused" label is a suggestion, not definitive
- Built-in tools (Read, Write, Edit, Glob, Grep, Bash) are always available regardless of settings
