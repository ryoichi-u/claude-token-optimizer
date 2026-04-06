---
description: Compress CLAUDE.md context while preserving quality (learning-based)
allowed-tools: Read, Write, Edit, Glob, Grep, Bash(wc*), Bash(date*), Bash(ls*)
argument-hint: "[<subdir> | --all] [--dry-run] [--lang en|ja|auto]"
---

# CLAUDE.md Context Optimization

Args: $ARGUMENTS

## Overview

Analyze CLAUDE.md files for token consumption and compress them while preserving quality.
Past optimization results are tracked in a learning log to improve accuracy over time.

## Mode

- `--all`: All CLAUDE.md files in the project (root + subdirectories)
- `--dry-run`: Analysis and proposals only (no file changes)
- `--lang`: Token estimation language (`en` = 0.75, `ja` = 2.3, `auto` = detect, default: `auto`)
- `<subdir>`: Specific subdirectory's CLAUDE.md only
- No args: Root CLAUDE.md only

---

## Step 0: Load Learning Data

1. Search for learning log at:
   - `docs/context-optimization-log.jsonl`
   - `.claude/context-optimization-log.jsonl`
   If neither exists, skip (first run).
2. Extract from past records:
   - **Success patterns**: `"result": "success"` — techniques and reduction rates that worked
   - **Failure/rollback patterns**: `"result": "reverted"` — patterns to avoid
   - **User feedback**: `"feedback"` field contents, if present
3. Prioritize proven techniques; avoid previously failed patterns.

## Step 1: Current State Analysis

### 1.1 Identify Target Files

```
No args:     ./CLAUDE.md
<subdir>:    ./<subdir>/CLAUDE.md
--all:       ./CLAUDE.md + ./**/CLAUDE.md (use Glob)
```

### 1.2 Collect Metrics

For each file (run in parallel):

```bash
wc -l < {file}      # Lines
wc -m < {file}      # Characters
wc -c < {file}      # Bytes (for language detection)
```

Token estimation multiplier:
- `--lang en`: 0.75
- `--lang ja`: 2.3
- `--lang auto` (default): MultibytePct = (Bytes - Chars) / Bytes × 100. If >= 20% → 2.3, else → 0.75

### 1.3 Section Analysis

Read each file and count lines per `## ` heading. Display:

```
| File | Lines | Chars | Est. Tokens | Largest Section |
```

## Step 2: Detect Compression Candidates

Apply the following techniques in order. **Use learning data from Step 0 to adjust priority.**

### Technique Catalog

| ID | Technique | Condition | Risk |
|---|---|---|---|
| T1 | **Deduplication** | Same info in root and subdirectory CLAUDE.md files | None |
| T2 | **Section Extraction** | Low-reference-frequency sections → move to separate file, leave link | Minor (1 extra lookup) |
| T3 | **Table Compression** | Detailed bullet lists → single-row summary table | None |
| T4 | **Code Block Reduction** | Redundant command examples (3+ similar blocks) → consolidate | None |
| T5 | **Stale Info Removal** | "Future plans" already implemented; deprecated feature details | None |
| T6 | **Verbose Simplification** | Same concept explained multiple times in different words | None |
| T7 | **Tree Simplification** | Overly detailed ASCII directory trees → key directories only | None |

### Detection Rules

For each technique:
1. Identify affected sections (name + line range)
2. Calculate current and estimated post-compression line counts
3. Compute reduction percentage
4. **Skip** if learning data shows a failure record for the same technique + same file

## Step 3: Display Proposals

```markdown
## Optimization Proposals: {filename}

Current: {lines} lines / {chars} chars / ~{tokens} tokens

| # | Technique | Target Section | Before | After | Reduction | Risk |
|---|---|---|---|---|---|---|
| 1 | T3: Table Compression | Agent List | 95 lines | 18 lines | -77 lines | None |
| 2 | T2: Section Extraction | Setup Guide | 38 lines | 2 lines | -36 lines | Minor |

Total estimated reduction: -{N} lines / -{M} chars / ~-{K} tokens ({P}% reduction)
```

### If `--dry-run`

Display proposals and end with: "Dry-run mode — no changes made. Remove `--dry-run` to apply."

## Step 4: Apply Compression

Only if NOT `--dry-run`.

### 4.1 Confirm with User

Show proposals and ask: "Apply these optimizations?"
Proceed only on approval.

### 4.2 Apply Changes

Apply each proposal in order:

1. **T1 (Deduplication)**: Remove content from child that duplicates root, or vice versa
2. **T2 (Section Extraction)**: Write section content to `docs/{topic}.md` → replace section body with link
3. **T3 (Table Compression)**: Convert bullet lists to table format
4. **T4 (Code Block Reduction)**: Merge similar command examples into one, note variations in comments
5. **T5 (Stale Removal)**: Delete obsolete sections/lines
6. **T6 (Verbose Simplification)**: Rewrite concisely
7. **T7 (Tree Simplification)**: Keep only key directories, summarize subdirectories

### 4.3 Post-Compression Quality Check

Re-read compressed file and verify:
- No required sections are missing (sections marked as mandatory in the original)
- Extracted section links point to files that actually exist (Glob check)
- Information is **moved or compressed, never deleted** — content must remain accessible

## Step 5: Record Results (Learning Log)

### 5.1 Log Entry

Append to learning log (prefer `docs/context-optimization-log.jsonl`; create if absent):

```jsonl
{"date": "YYYY-MM-DD", "file": "CLAUDE.md", "before": {"lines": N, "chars": M, "est_tokens": K}, "after": {"lines": N2, "chars": M2, "est_tokens": K2}, "reduction_pct": P, "techniques": ["T1", "T3"], "details": [...], "result": "success"}
```

### 5.2 Collect Feedback

Display after completion:

```
Optimization complete:
- {filename}: {before} lines → {after} lines ({reduction}% reduction)

Any issues with the result?
- No issues → continue to next task
- Issues → describe which sections need adjustment (will be reflected in future optimizations)
```

If user provides feedback, append `"feedback"` field to the log entry.
If rollback is needed, suggest `git checkout -- {file}` and record `"result": "reverted"`.

## Step 6: Summary Report

```markdown
## Context Optimization Report

| File | Before | After | Reduction |
|------|--------|-------|-----------|
| CLAUDE.md | {N} lines / ~{K} tok | {N2} lines / ~{K2} tok | {P}% |

Applied techniques:
- T3: Table compression on Agent List (-77 lines)
- T2: Extracted Setup Guide to docs/setup.md (-36 lines)

Extracted files:
- docs/setup.md (new)

Learning log: docs/context-optimization-log.jsonl (recorded)
Total optimizations: {N} runs (success: {S}, adjusted: {A}, reverted: {R})
```

---

## Compression Rules (must not violate)

1. **Never delete information** — move, compress, or simplify only. Always leave a link when extracting to a separate file.
2. **Do not compress sections marked as mandatory** — sections that other tools, hooks, or validation depend on.
3. **Do not compress security-related sections** — git management policies, secret handling rules, etc.
4. **Do not reapply failed patterns** — same file + same technique combination in learning log with `"result": "reverted"`.
5. **Do not modify frontmatter** — `---` blocks in any file are off-limits.
