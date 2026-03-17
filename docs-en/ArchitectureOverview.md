# Architecture Overview

## System Design

The ClaudeCode Autonomous Development System is built around the **Triple Loop Architecture** — three interconnected loops that Claude executes autonomously to plan, build, and validate software.

---

## Triple Loop Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   Triple Loop 15H (2-Cycle)                  │
│                                                             │
│  Cycle 1 (7.5H)                    Cycle 2 (7.5H)          │
│  ┌──────────────────────────┐      ┌──────────────────────┐ │
│  │ Monitor (30m)            │      │ Monitor (30m)        │ │
│  │ Build   (2h)             │  ──► │ Build   (2h)         │ │
│  │ Verify  (4h)             │      │ Verify  (4h)         │ │
│  │ Finalize (1h)            │      │ Finalize (1h)        │ │
│  └──────────────────────────┘      └──────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

### Monitor Loop (30 min)
Analyzes the repository state and creates a prioritized task list.

**Inputs:** `git status`, error logs, `TASKS.md`, GitHub Issues  
**Outputs:** Prioritized task list, risk assessment

### Build Loop (2–4 hours)
Implements the highest-priority tasks.

**Inputs:** Task list from Monitor Loop  
**Outputs:** Working code, Git commits, pull requests

### Verify Loop (3–4 hours)
Validates quality, security, and performance.

**Inputs:** Build Loop output  
**Outputs:** Test results, security report, merge/reject decision

---

## Technology Stack

| Layer | Technology |
|-------|-----------|
| AI Engine | Claude Sonnet 4.5 (default) / Opus 4.6 / Haiku 4.5 |
| Runtime | Claude Code CLI 2.0 |
| IDE Integration | VS Code Native Extension (Beta) |
| External Tools | MCP (Model Context Protocol) |
| Agent Automation | Claude Agent SDK |
| Version Control | Git / GitHub |
| CI/CD | GitHub Actions |
| Configuration | `.claude/settings.json` + `CLAUDE.md` |

---

## Feature Overview

### Checkpoints
Every tool call automatically saves a snapshot. Restore with `/rewind` or `Esc×2`.

```
Tool call → Auto snapshot → Execute → Success? Continue : /rewind
```

### Hooks
Lifecycle events let you attach shell commands to Claude's actions:

```json
{
  "hooks": {
    "PostToolUse": [{ "matcher": {"tool_name": "Write"}, "hooks": [{"type": "command", "command": "npm test"}] }],
    "PreToolUse":  [{ "matcher": {"tool_name": "bash", "tool_input": ".*rm -rf.*"}, "hooks": [{"type": "block"}] }]
  }
}
```

### Subagents
The main agent can delegate tasks to parallel subagents:

```
Main Agent (Orchestrator)
  ├── Backend Subagent   → Implements API endpoints
  ├── Frontend Subagent  → Implements UI components
  └── Testing Subagent   → Creates test suites
```

### MCP (Model Context Protocol)
Connect external tools directly into Claude's context:

```
Claude Code ──── GitHub MCP ──── Issues, PRs, repos
           ──── Slack MCP  ──── Team channels
           ──── DB MCP     ──── Queries, schema
```

---

## Configuration Files

```
.claude/
├── CLAUDE.md          ← AI instructions (natural language)
├── settings.json      ← System settings (JSON)
├── commands/          ← Custom /slash commands
├── hooks/             ← Hook shell scripts
└── mcp-configs/       ← MCP server configs
```

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Role definition, Triple Loop instructions, coding standards |
| `settings.json` | Tool permissions, auto-approve rules, model, Hooks |

---

## Related Documents

- [Quick Start](./QuickStart.md)
- [Settings Guide](./SettingsGuide.md)
- Japanese: [01_システム概要](../01_システム概要(SystemOverview)/02_アーキテクチャ概要(ArchitectureOverview).md)
