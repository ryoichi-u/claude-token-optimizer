# CLAUDE.md Optimization: Before & After Example

A real-world example of optimizing a monorepo root CLAUDE.md file.

## Before: 348 lines / ~11,500 chars / ~8,300 tokens

```markdown
# Project CLAUDE.md

## Agents

### agent-alpha
- Status: Active
- Purpose: Collects data from source A and generates daily reports
- MCP servers required: slack, calendar
- Available commands:
  - /daily: Generate daily report
  - /weekly: Generate weekly report
- Scripts:
  - scripts/collect.py: Data collection
  - scripts/format.py: Report formatting
- Configuration: config/settings.yaml
- Output: reports/daily/

### agent-beta
- Status: Active
- Purpose: Monitors changes in external documents
- MCP servers required: drive
- Available commands:
  - /diff: Show recent changes
(... repeated for 12+ agents, ~95 lines total ...)

## Slack Token Management

### Personal Workspace Setup
1. Create a Slack app at api.slack.com
2. Add the following scopes: channels:history, chat:write, ...
3. Install to workspace
4. Copy the Bot User OAuth Token
5. Store in .env as SLACK_BOT_TOKEN=xoxb-...
(... 38 lines of detailed setup instructions ...)

## Batch Sync Configuration

### Setup Steps
1. Install dependencies: npm install
2. Configure .env file with credentials
3. Run initial sync: node scripts/sync.js --init
(... 42 lines of sync documentation ...)

## New Agent Creation Guide

When creating a new agent:
1. Create directory: mkdir new-agent
2. Add CLAUDE.md with required sections
3. Add .claude/commands/ for slash commands
4. Register in root CLAUDE.md agent table
5. Add scheduler entry if needed
6. Test with --dry-run

## Directory Structure

├── CLAUDE.md
├── README.md
├── .gitignore
├── .claude/
│   ├── commands/
│   │   ├── deploy.md
│   │   ├── report.md
│   │   ├── analyze.md
│   │   └── ...
│   └── agents/
│       ├── reporter.md
│       └── collector.md
├── shared/
│   ├── scripts/
│   │   ├── validate.sh
│   │   ├── format.py
│   │   └── utils.py
│   └── schemas/
│       ├── dataset-a/
│       └── dataset-b/
├── agent-alpha/
│   ├── CLAUDE.md
│   ├── scripts/
│   ├── config/
│   └── ...
(... 22 lines of full tree ...)

## Future Directions

- [ ] Add natural language query interface
- [x] Implement batch processing (done 2026-01)
- [x] Add monitoring dashboard (done 2026-02)
- [ ] Consider migration to new API version
```

## After: 113 lines / ~3,614 chars / ~2,800 tokens

```markdown
# Project CLAUDE.md

## Agents

| Agent | Status | Purpose | Commands |
|-------|--------|---------|----------|
| agent-alpha | Active | Data collection → daily reports | /daily, /weekly |
| agent-beta | Active | External document change monitoring | /diff |
| agent-gamma | Active | Research & investigation | /research |
| ... | ... | ... | ... |

See each agent's own CLAUDE.md for details (MCP, config, scripts).

## Directory Structure

```
project/
├── CLAUDE.md, .claude/, shared/
├── reports/          ← output (symlinks + integrated views)
├── scheduler/        ← launchd automation
└── <name>-agent/     ← per-agent: CLAUDE.md / commands / scripts / config
```

## References

- [Slack Token Management](docs/slack-tokens.md)
- [Batch Sync Configuration](docs/batch-sync.md)
- [New Agent Creation Guide](docs/new-agent-guide.md)
```

## Techniques Applied

| Technique | Target | Lines Saved |
|-----------|--------|-------------|
| T3: Table Compression | Agent list (bullet → table) | -77 |
| T2: Section Extraction | Slack token management → docs/ | -36 |
| T2: Section Extraction | Batch sync config → docs/ | -41 |
| T2: Section Extraction | New agent guide → docs/ | -5 |
| T5: Stale Removal | "Future Directions" (2 items done) | -5 |
| T7: Tree Simplification | Directory tree (full → key only) | -14 |
| T6: Verbose Simplification | Scheduler section → README link | -13 |

## Results

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Lines | 348 | 113 | -67% |
| Characters | 11,500 | 3,614 | -69% |
| Est. Tokens | 8,300 | 2,800 | -66% |

**No information was lost** — all content was either compressed (tables) or moved to docs/ with links.
