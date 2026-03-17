# Settings Guide: settings.json Configuration Reference

---

## Overview of settings.json vs CLAUDE.md

Claude Code uses two complementary configuration mechanisms:

| File | Purpose | Scope |
|------|---------|-------|
| `settings.json` | Machine-readable runtime configuration (tool permissions, model selection, hooks, MCP, session options) | Project-level or user-level |
| `CLAUDE.md` | Natural-language instructions appended to the system prompt (coding style, project context, behavioral guidelines) | Project-level or user-level |

**File locations and precedence:**

```
High priority <─────────────────────────────> Low priority

Project-level              User-level
.claude/settings.json      ~/.claude/settings.json
```

Project-level settings override user-level settings. When both exist, they are merged, with the project-level values taking precedence on conflicts.

---

## .claude/ Directory Structure

```
.claude/
├── settings.json          ← Main configuration file
├── CLAUDE.md              ← Project-specific system prompt supplement
├── skills/                ← Custom skill definitions (future feature)
├── agents/                ← Custom agent definitions
├── commands/              ← Custom slash commands
│   ├── review.md          ← Definition for /review command
│   └── deploy.md          ← Definition for /deploy command
├── hooks/                 ← Hook scripts
│   ├── pre-commit.sh      ← Pre-commit checks
│   └── post-write.sh      ← Post-file-write actions
└── mcp-configs/           ← MCP server configurations
    ├── github.json        ← GitHub MCP
    └── slack.json         ← Slack MCP
```

---

## Model Selection (`"model"` field)

The `"model"` field sets the default Claude model for all sessions in the project.

```json
{
  "model": "claude-sonnet-4-5"
}
```

### Model Selection Guide

| Model | Recommended Use | Cost |
|-------|----------------|------|
| `claude-sonnet-4-5` | Everyday development tasks (**default**) | Medium |
| `claude-opus-4-6` | Complex architecture design, deep analysis | High |
| `claude-haiku-4-5` | Simple tasks, high-speed processing | Low |

You can override the model dynamically within a session using the `/model` command:

```
/model claude-opus-4-6
```

---

## Tool Permissions (`"permissions"` block)

The `"permissions"` block controls which tools Claude Code is allowed to use, and which are explicitly denied.

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Write",
      "Edit",
      "bash",
      "Glob",
      "Grep",
      "WebFetch",
      "TodoRead",
      "TodoWrite"
    ],
    "deny": [
      "bash(rm -rf*)",
      "bash(sudo rm*)",
      "WebFetch(*.malicious-site.com*)"
    ]
  }
}
```

- **`allow`**: List of tool names that Claude Code may use. Wildcards and pattern matching are supported for `bash` and `WebFetch`.
- **`deny`**: List of tools or tool patterns that are unconditionally blocked, regardless of `allow` entries. Deny rules take precedence.

**Tip:** Use granular `deny` patterns rather than broad `allow` lists to follow the principle of least privilege.

---

## Auto-Approve Rules (`"autoApprove"`)

The `"autoApprove"` block controls which tool invocations are automatically approved without requiring user confirmation.

> **Note**: The `//` comments below are for illustration only. Standard JSON does not support comments — remove them before using in your `settings.json`.

```json
{
  "autoApprove": {
    "enabled": true,
    "rules": [
      // Read-only operations — always auto-approve
      { "tool": "Read",  "auto": true },
      { "tool": "Grep",  "auto": true },
      { "tool": "Glob",  "auto": true },

      // Test execution — auto-approve
      { "tool": "bash", "pattern": "npm test.*",  "auto": true },
      { "tool": "bash", "pattern": "pytest.*",    "auto": true },

      // Production deployments — require manual approval
      { "tool": "bash", "pattern": ".*prod.*deploy.*", "auto": false }
    ]
  }
}
```

- Set `"enabled": false` to disable auto-approval globally and require manual confirmation for every tool call.
- `"pattern"` accepts regular expressions matched against the tool's input string.
- Rules are evaluated in order; the first matching rule wins.

---

## Hooks Configuration

The `"hooks"` block attaches shell commands to Claude Code lifecycle events. See [HooksGuide.md](./HooksGuide.md) for the full reference.

```json
{
  "hooks": {
    "PreToolUse":  [...],
    "PostToolUse": [...],
    "Notification": [...]
  }
}
```

Hooks can be used to auto-run tests after file writes, block dangerous commands, send notifications, or log activity.

---

## Context and Session Settings

> **Note**: The `//` comments below are for illustration only. Standard JSON does not support comments — remove them before using in your `settings.json`.

```json
{
  "context": {
    "autoLoadFiles": ["README.md", "CLAUDE.md", "package.json"],
    "maxContextFiles": 50,
    "includeGitHistory": true
  },

  "output": {
    "verbosity": "normal",      // "quiet" | "normal" | "verbose"
    "colorEnabled": true,
    "progressIndicator": true
  },

  "session": {
    "checkpointsEnabled": true,
    "historyRetentionDays": 30,
    "maxTurnsPerSession": 200
  }
}
```

---

## Configuration Patterns

### Pattern 1: Safety-First (Production / Shared Repositories)

Minimal permissions — read-only, no auto-approve:

```json
{
  "model": "claude-sonnet-4-6",
  "permissions": {
    "allow": ["Read", "Grep", "Glob"],
    "deny": ["Write", "Edit", "bash", "Write(**/secrets/**)"]
  },
  "autoApprove": {
    "enabled": false
  }
}
```

Use this when: reviewing unfamiliar repositories, onboarding, or working in production environments.

### Pattern 2: Full Autonomous Development (Triple Loop)

All tools enabled with smart auto-approval:

(See the Node.js example below for a full Pattern 2 configuration.)

### Pattern 3: Code Review Only

Read access + bash for test execution, Opus model for deeper analysis:

```json
{
  "model": "claude-opus-4-6",
  "permissions": {
    "allow": ["Read", "Grep", "Glob", "bash(npm test)", "bash(pytest)"],
    "deny": ["Write", "Edit"]
  },
  "autoApprove": {
    "enabled": true,
    "rules": [
      { "tool": "Read", "auto": true },
      { "tool": "Grep", "auto": true }
    ]
  }
}
```

Use this when: performing code reviews, security audits, or CI-only analysis.

---

## Pattern 2: Full Autonomous Development — Node.js Example

A configuration suited for an autonomous development workflow on a Node.js/TypeScript project:

```json
{
  "model": "claude-sonnet-4-5",

  "permissions": {
    "allow": ["Read", "Write", "Edit", "bash", "Glob", "Grep", "WebFetch"],
    "deny": [
      "bash(sudo rm -rf /*)",
      "bash(DROP TABLE*)",
      "bash(*--force*push*)"
    ]
  },

  "autoApprove": {
    "enabled": true,
    "rules": [
      { "tool": "Read",  "auto": true },
      { "tool": "Grep",  "auto": true },
      { "tool": "Glob",  "auto": true },
      { "tool": "Write", "pattern": "src/.*", "auto": true },
      { "tool": "bash",  "pattern": "npm (test|lint|build).*", "auto": true },
      { "tool": "bash",  "pattern": "git (add|commit|status|log|diff).*", "auto": true }
    ]
  },

  "hooks": {
    "PostToolUse": [
      {
        "matcher": { "tool_name": "Write" },
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint -- --fix $CLAUDE_FILE_PATH",
            "on_failure": "warn"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": { "tool_name": "bash", "tool_input": "git commit.*" },
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint && npm run type-check",
            "on_failure": "block"
          }
        ]
      }
    ]
  },

  "context": {
    "autoLoadFiles": ["README.md", "CLAUDE.md", "package.json"],
    "maxContextFiles": 50,
    "includeGitHistory": true
  },

  "session": {
    "checkpointsEnabled": true,
    "maxTurnsPerSession": 500
  },

  "mcp": {
    "enabled": true,
    "configPath": ".claude/mcp-configs/"
  }
}
```

---

## Example settings.json for Python Project

A configuration suited for a Python project using pytest:

```json
{
  "model": "claude-sonnet-4-5",

  "permissions": {
    "allow": ["Read", "Write", "Edit", "bash", "Glob", "Grep", "WebFetch"],
    "deny": [
      "bash(sudo rm -rf /*)",
      "bash(DROP TABLE*)",
      "bash(*--force*push*)"
    ]
  },

  "autoApprove": {
    "enabled": true,
    "rules": [
      { "tool": "Read",  "auto": true },
      { "tool": "Grep",  "auto": true },
      { "tool": "Glob",  "auto": true },
      { "tool": "Write", "pattern": "src/.*\\.py$", "auto": true },
      { "tool": "bash",  "pattern": "pytest.*",     "auto": true },
      { "tool": "bash",  "pattern": "pip.*",        "auto": true },
      { "tool": "bash",  "pattern": "git (add|commit|status|log|diff).*", "auto": true }
    ]
  },

  "hooks": {
    "PostToolUse": [
      {
        "matcher": { "tool_name": "Write", "tool_input": ".*\\.py$" },
        "hooks": [
          {
            "type": "command",
            "command": "python -m flake8 $CLAUDE_FILE_PATH --max-line-length=120",
            "on_failure": "warn"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": { "tool_name": "bash", "tool_input": "git commit.*" },
        "hooks": [
          {
            "type": "command",
            "command": "python -m flake8 . && python -m mypy src/",
            "on_failure": "block"
          }
        ]
      }
    ]
  },

  "context": {
    "autoLoadFiles": ["README.md", "CLAUDE.md", "pyproject.toml", "requirements.txt"],
    "maxContextFiles": 50,
    "includeGitHistory": true
  },

  "session": {
    "checkpointsEnabled": true,
    "maxTurnsPerSession": 500
  }
}
```

---

## Validating Your Configuration

```bash
# Check settings.json syntax
claude config validate

# Display the currently active merged configuration
claude config show

# Inspect a specific configuration value
claude config get permissions.allow
```

---

## Custom Slash Commands

Place Markdown files in `.claude/commands/` to create custom `/slash` commands:

```markdown
<!-- .claude/commands/review.md -->
# /review command

Run this command to perform a code review.

## Steps

1. List all changed files
2. Evaluate code quality for each file
3. Detect security issues
4. Output improvement suggestions
```

Invoke with:

```
/review
```

---

## Related Documents

- [HooksGuide.md](./HooksGuide.md)
- [MCPGuide.md](./MCPGuide.md)
- [ArchitectureOverview.md](./ArchitectureOverview.md)
- [QuickStart.md](./QuickStart.md)
