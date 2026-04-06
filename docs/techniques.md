# Token Optimization Techniques Reference

A comprehensive catalog of techniques for reducing token consumption in Claude Code projects.

## 1. Static Context Optimization

Techniques that reduce tokens consumed at session start (CLAUDE.md, commands, agent definitions).

### T1: Deduplication

**What**: Remove identical information that appears in both root and subdirectory CLAUDE.md files.

**When**: Monorepo setups where child CLAUDE.md files repeat root-level rules.

**Example**:
```
# Root CLAUDE.md
## Output Rules
- Always use YAML frontmatter
- No placeholder text

# child-agent/CLAUDE.md  (BEFORE)
## Output Rules           ← duplicates root
- Always use YAML frontmatter
- No placeholder text
## Agent-Specific Rules
- ...

# child-agent/CLAUDE.md  (AFTER)
## Agent-Specific Rules   ← root rules inherited automatically
- ...
```

**Risk**: None. Claude Code loads root CLAUDE.md automatically for all subdirectories.

### T2: Section Extraction

**What**: Move low-reference-frequency sections to separate files, leaving only a link.

**When**: Sections about setup procedures, historical decisions, or reference data that are rarely needed.

**Example**:
```
# BEFORE (in CLAUDE.md)
## Slack Token Management
(38 lines of detailed setup instructions)

# AFTER (in CLAUDE.md)
## Reference
- [Slack Token Management](docs/slack-tokens.md)
```

**Risk**: Minor — requires one extra file read when the information is needed.

### T3: Table Compression

**What**: Convert detailed bullet lists into compact summary tables.

**When**: Lists of items with repeated structure (agents, commands, configurations).

**Example**:
```
# BEFORE (95 lines)
## Agents
### slack-agent
- Status: Active
- Purpose: Daily reports from Slack
- MCP: slack
- Commands: /daily, /weekly

### docs-agent
- Status: Active
- Purpose: Document change tracking
...

# AFTER (18 lines)
## Agents
| Agent | Status | Purpose | Commands |
|-------|--------|---------|----------|
| slack-agent | Active | Daily reports from Slack | /daily, /weekly |
| docs-agent | Active | Document change tracking | /diff |
```

**Risk**: None.

### T4: Code Block Reduction

**What**: Consolidate redundant code examples into one representative example.

**When**: Multiple similar command examples showing minor variations.

**Risk**: None.

### T5: Stale Information Removal

**What**: Delete outdated content — implemented "future plans", deprecated feature details, resolved TODOs.

**When**: Regular maintenance (monthly recommended).

**Risk**: None.

### T6: Verbose Simplification

**What**: Rewrite redundant explanations concisely.

**When**: Same concept is explained multiple times in different words.

**Risk**: None.

### T7: Tree Simplification

**What**: Reduce overly detailed ASCII directory trees to key directories only.

**When**: Full directory trees with every file listed.

**Risk**: None.

---

## 2. Runtime Optimization

Techniques that reduce tokens consumed during task execution.

### Pre-filtering

**What**: Use scripts (Python, shell) to pre-process data before passing it to Claude.

**When**: Processing API responses, database results, or large file collections.

**Savings**: 60-80% reduction in data volume.

**Example**:
```python
# Instead of passing raw Slack API response (10,000+ messages):
# 1. Filter by date range
# 2. Extract only: author, timestamp, text (discard metadata)
# 3. Limit to top 50 results
# 4. Save as compact JSON
# 5. Claude reads the filtered JSON only
```

### Phased Execution

**What**: Split large tasks into independent phases, each with its own context window.

**When**: Multi-source data aggregation, complex analysis pipelines.

**Example**:
```
Phase 1: Data collection (separate context)
  → Save results to files

Phase 2: Per-source analysis (parallel, separate contexts)
  → Each sub-agent reads only its source data

Phase 3: Integration (new context)
  → Read only summaries from Phase 2
```

### Sampling

**What**: Process a representative subset instead of all items.

**When**: Analyzing collections of reports, logs, or files.

**Strategies**:
- Recent N items: "Analyze the 10 most recent reports"
- Head + tail: "For files over 500 lines, read first 200 + last 100"
- Random sample: "Select 5 random items from the collection"

### Model Selection

**What**: Use lighter models for routine tasks, reserving capable models for complex work.

**When**: Batch processing, data extraction, summarization tasks.

**Cost impact**: Sonnet is ~1/5 the cost of Opus for comparable quality on structured tasks.

### Frequency Limiting

**What**: Cap the number of items processed per cycle.

**When**: Automated pipelines that run daily/hourly.

**Example**: "Extract max 2 knowledge items per day" prevents token consumption spikes.

---

## 3. Tool Definition Optimization

### Minimize Registered Tools

**What**: Each tool definition consumes ~150-300 tokens. Remove unused tool permissions.

**Detection**: Cross-reference `settings.local.json` permissions with actual usage in commands.

### MCP Server Selection

**What**: Only enable MCP servers needed for the current project.

**Impact**: Each MCP server adds all its tool definitions to the context.

---

## 4. Token Estimation

Since Claude Code doesn't expose exact token counts, we use character-based estimation:

| Content Type | Multiplier | Basis |
|-------------|-----------|-------|
| English text | 0.75 | ~4 chars per token (GPT/Claude average) |
| CJK-mixed text | 2.3 | Multi-byte encoding + tokenizer splitting |
| Code | 0.5-0.75 | Depends on identifier length and whitespace |
| Tool definitions | ~200 per tool | Empirical average including schema JSON |

### Auto-Detection

```
MultibytePct = (ByteCount - CharCount) / ByteCount × 100
If MultibytePct >= 20%: use CJK multiplier (2.3)
Else: use English multiplier (0.75)
```
