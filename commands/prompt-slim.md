---
description: Compress slash command definition files to reduce per-invocation token cost
allowed-tools: Read, Write, Edit, Glob, Bash(wc*)
argument-hint: "[<command-name> | --all] [--dry-run]"
---

# Prompt Slim

Args: $ARGUMENTS

## Overview

Slash command definition files (`.claude/commands/*.md`) are injected into the context window
every time the command is invoked. Reducing their size directly saves tokens per invocation.

This skill analyzes command files for compression opportunities without changing their behavior.

## Mode

- `<command-name>`: Analyze a specific command (e.g., `deploy` for `.claude/commands/deploy.md`)
- `--all`: Analyze all commands in `.claude/commands/`
- `--dry-run`: Analysis only, no changes
- No args: Analyze all commands (same as `--all`)

---

## Step 1: Discover and Measure

1. Glob `.claude/commands/*.md`
2. For each file:
   - `wc -l` and `wc -m`
   - Estimate tokens (auto-detect language multiplier)
3. Sort by estimated tokens, descending

Display overview:

```
| Command | Lines | Est. Tokens |
|---------|-------|-------------|
| /integrated-report | 180 | 4,140 |
| /deploy | 95 | 2,185 |
| ... | ... | ... |
| **Total** | **{N}** | **{K}** |
```

## Step 2: Detect Compression Opportunities

Apply the following techniques to each command file:

### Technique Catalog

| ID | Technique | What to Look For |
|---|---|---|
| S1 | **Step Preamble Removal** | Filler phrases like "Execute the following steps:", "In this step, we will..." — remove and keep only the numbered list |
| S2 | **Comment Trimming** | Excessive inline comments in code blocks — keep only essential ones |
| S3 | **Table Column Dedup** | Table columns that repeat information from another column |
| S4 | **Output Example Trimming** | Overly detailed output format examples — keep only structural skeleton |
| S5 | **Condition Table** | Verbose if/else prose → compact condition table |

### Detection Rules

For each technique:
1. Identify affected lines (line range)
2. Estimate line count before and after
3. Calculate reduction

**Critical constraint**: NEVER modify frontmatter (`---` block). Changing `allowed-tools` would alter permissions.

## Step 3: Display Proposals

For each command file with detected opportunities:

```markdown
### /command-name ({current_tokens} tokens)

| # | Technique | Location | Before | After | Reduction |
|---|---|---|---|---|---|
| 1 | S1: Step Preamble | Lines 25-30 | 6 lines | 0 lines | -6 |
| 2 | S4: Output Example | Lines 80-120 | 40 lines | 15 lines | -25 |

Estimated reduction: -{N} lines / ~-{K} tokens
```

### If `--dry-run`

Show proposals and exit.

## Step 4: Apply (if not --dry-run)

For each file with approved proposals:

1. Read the current content
2. Apply compressions in reverse line-number order (to preserve line numbers)
3. Re-measure and verify:
   - Frontmatter unchanged
   - Step numbering still sequential
   - No instructions lost (compressed, not deleted)

## Step 5: Summary

```markdown
## Prompt Slim Report

| Command | Before | After | Reduction |
|---------|--------|-------|-----------|
| /integrated-report | 180 lines / ~4,140 tok | 140 lines / ~3,220 tok | 22% |
| /deploy | 95 lines / ~2,185 tok | 82 lines / ~1,886 tok | 14% |

Total: {before_total} → {after_total} tokens (~{pct}% reduction)
```

## Notes

- This skill compresses the **instruction text**, not the behavior
- Commands under 30 lines are skipped (already concise)
- After compression, test the command once to verify it still works as expected
