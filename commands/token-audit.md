---
description: "Analyze token usage of CLAUDE.md, commands, and agents / CLAUDE.md・コマンド・エージェント定義のトークン消費を分析"
allowed-tools: Read, Glob, Grep, Bash(wc*)
argument-hint: "[<path> | --all]"
---

# Token Audit

Args: $ARGUMENTS

## Overview

Analyze and visualize token consumption across all Claude Code configuration files in the project. Identifies the largest consumers of context window space.

## Mode

- `--all`: Scan all CLAUDE.md + `.claude/commands/` + `.claude/agents/`
- `<path>`: Analyze specific file or directory
- No args: Analyze current directory's CLAUDE.md and `.claude/` only

---

## Step 0: Language Detection Helper

For each file, determine the token estimation multiplier:

```
Bytes = wc -c < file
Chars = wc -m < file
MultibytePct = (Bytes - Chars) / Bytes * 100

If MultibytePct >= 20%: multiplier = 2.3 (CJK-mixed)
Else: multiplier = 0.75 (mostly ASCII/English)
```

## Step 1: Discover Target Files

Use Glob to find all relevant files:

```
CLAUDE.md                      # Root context
**/CLAUDE.md                   # Nested contexts (monorepo agents, etc.)
.claude/commands/*.md           # Slash commands
.claude/agents/*.md             # Custom agent definitions
```

## Step 2: Measure Each File

For every discovered file, collect:

1. `wc -l` — line count
2. `wc -m` — character count
3. `wc -c` — byte count (for language detection)
4. Estimated tokens = chars × multiplier (from Step 0)
5. Category: `CLAUDE.md` / `Command` / `Agent`

Run `wc` commands in parallel for efficiency.

## Step 3: Section-Level Breakdown

For the **top 3 largest files** by estimated tokens:

1. Read the file
2. Split by `## ` headings
3. Count lines per section
4. Report the top 5 sections by size

## Step 4: Output Report

Display in terminal:

```markdown
## Token Audit Report

Scan date: YYYY-MM-DD
Project: {directory name}

### Summary

| Category | Files | Total Lines | Est. Tokens | Share |
|----------|-------|-------------|-------------|-------|
| CLAUDE.md (root) | 1 | 200 | 4,600 | 28% |
| CLAUDE.md (nested) | 5 | 800 | 18,400 | -- |
| Commands | 12 | 600 | 13,800 | 42% |
| Agent definitions | 3 | 150 | 3,450 | 10% |

**Estimated session-start context: ~40,250 tokens**

### Top 5 Largest Files

| File | Lines | Est. Tokens |
|------|-------|-------------|
| CLAUDE.md | 200 | 4,600 |
| .claude/commands/deploy.md | 150 | 3,450 |
| ... | ... | ... |

### Section Breakdown (largest files)

#### CLAUDE.md
| Section | Lines | Est. Tokens |
|---------|-------|-------------|
| Agent List | 50 | 1,150 |
| Shared Modules | 30 | 690 |
| ... | ... | ... |

### Recommendations

- Files over 200 lines: consider running `/optimize-context`
- Commands over 100 lines: consider running `/prompt-slim`
- If > 30 tools registered: consider running `/tool-diet`
```

## Notes

- Token estimates are approximations. Actual tokenization depends on the model's tokenizer.
- Multiplier 0.75 ≈ 4 chars/token (typical for English). 2.3 accounts for CJK multi-byte encoding overhead.
- This skill is read-only — it never modifies files.
