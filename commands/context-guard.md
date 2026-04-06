---
description: Detect patterns that inject excessive data into the context window
allowed-tools: Read, Glob, Grep, Bash(wc*)
argument-hint: "[--all]"
---

# Context Guard

Args: $ARGUMENTS

## Overview

Scan slash commands and CLAUDE.md files for patterns that can cause excessive token consumption
at runtime. These patterns may cause context window overflow, degraded output quality,
or unnecessary cost.

This skill is read-only — it identifies risks and suggests mitigations.

## Step 1: Scan Targets

Glob for all analysis targets:

```
CLAUDE.md
**/CLAUDE.md
.claude/commands/*.md
.claude/agents/*.md
```

## Step 2: Pattern Detection

Read each file and check for the following anti-patterns:

### Anti-Pattern Catalog

| ID | Pattern | Detection Heuristic | Risk |
|---|---|---|---|
| G1 | **Unbounded Read** | `Read` instruction without `limit` parameter or line-range guidance | High |
| G2 | **Full-Collection Loop** | Phrases: "read all files", "process every", "for each file in", "scan all" without a cap | High |
| G3 | **No Sampling** | Instructions to analyze 10+ items with no mention of "sample", "top N", "limit", or "first N" | Medium |
| G4 | **Raw Data Injection** | Instructions to pass API responses, DB results, or file contents directly to Claude without filtering/summarizing | High |
| G5 | **No Output Limit** | Command file with no mention of output length constraints, response limits, or summary-first approach | Low |
| G6 | **Recursive Glob** | `**/*.md` or similar recursive patterns without a depth or count limit | Medium |
| G7 | **Large File Warning Missing** | Instructions to read files that could be large (logs, data files) with no size check | Medium |

### Scoring

Each detected pattern gets a risk score:
- **High**: 3 points
- **Medium**: 2 points
- **Low**: 1 point

File risk level:
- **Low**: 0-2 points
- **Medium**: 3-5 points
- **High**: 6+ points

## Step 3: Generate Mitigations

For each detected pattern, suggest a specific mitigation:

| Pattern | Mitigation |
|---------|-----------|
| G1 | Add `limit: 200` or specify line range (e.g., "read lines 1-100") |
| G2 | Add explicit cap: "process the first 10 files" or "sample up to N" |
| G3 | Add sampling: "analyze a random sample of 5" or "focus on the top 10 by size" |
| G4 | Pre-filter with a script, or instruct to "summarize key fields only" |
| G5 | Add "keep response under N lines" or "summarize first, detail on request" |
| G6 | Add max depth or file count limit |
| G7 | Add size check: "if file > 500 lines, read first 200 + last 100" |

## Step 4: Output Report

```markdown
## Context Guard Report

Scan date: YYYY-MM-DD
Files scanned: {N}

### Summary

| Risk Level | Files |
|------------|-------|
| High | 2 |
| Medium | 5 |
| Low | 8 |
| Clean | 3 |

### High-Risk Files

#### .claude/commands/analyze-logs.md (Score: 8, High)

| # | Pattern | Location | Detail | Mitigation |
|---|---------|----------|--------|-----------|
| 1 | G2: Full Loop | Line 45 | "read all log files in data/" | Add cap: "process the 10 most recent log files" |
| 2 | G4: Raw Injection | Line 52 | "pass the API response to Claude" | Pre-filter with jq/Python, pass summary only |
| 3 | G1: Unbounded Read | Line 60 | "Read the output file" | Add `limit: 200` or check file size first |

#### CLAUDE.md (Score: 6, High)

| # | Pattern | Location | Detail | Mitigation |
|---|---------|----------|--------|-----------|
| ... | ... | ... | ... | ... |

### Medium-Risk Files
(similar format, abbreviated)

### Recommendations (Priority Order)

1. Fix High-risk files first — these can cause context overflow in production
2. Add sampling strategies to Medium-risk files
3. Low-risk items are informational — fix when convenient
```

## Notes

- False positives are possible: a "read all" in a context where "all" means 3 files is fine
- This skill flags patterns, not bugs — use judgment when acting on recommendations
- Pair with `/prompt-slim` to also reduce the static size of flagged command files
