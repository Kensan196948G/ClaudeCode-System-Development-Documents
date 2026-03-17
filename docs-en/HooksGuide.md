# Hooks Guide: Lifecycle Event Automation

---

## What are Hooks?

**Hooks** are a mechanism in Claude Code that binds shell commands or scripts to agent lifecycle events. They allow you to automate your development workflow flexibly — for example, running tests automatically after code changes, blocking dangerous tool invocations before they execute, or sending notifications when a session completes.

Hooks are defined in `.claude/settings.json` (project-level) or `~/.claude/settings.json` (user-level):

```json
{
  "hooks": {
    "PreToolUse":        [...],
    "PostToolUse":       [...],
    "SubagentStart":     [...],
    "SubagentStop":      [...],
    "Notification":      [...],
    "Stop":              [...],
    "SessionStart":      [...],
    "UserPromptSubmit":  [...],
    "MessageStart":      [...],
    "MessageStop":       [...]
  }
}
```

---

## Lifecycle Events

| Event | When It Fires | Typical Use |
|-------|--------------|-------------|
| **PreToolUse** | Before a tool is executed | Validation, confirmation dialogs, blocking |
| **PostToolUse** | After a tool finishes executing | Run tests, log results, send notifications |
| **SubagentStart** | When a subagent is launched | Logging, resource allocation |
| **SubagentStop** | When a subagent terminates | Collect results, cleanup |
| **Notification** | When Claude emits a notification | Desktop notifications, Slack alerts |
| **Stop** | When the session ends | Generate final reports, post-processing |
| **SessionStart** | When a session begins | Environment checks, initialization |
| **UserPromptSubmit** | After user input is submitted | Pre-process input, audit logging |
| **MessageStart** | When Claude begins a response | UI updates |
| **MessageStop** | When Claude finishes a response | Logging, cost tracking |

---

## Hook Configuration Structure

Each hook entry consists of a **matcher** that selects when the hook fires, and a **hooks** array that defines what to execute.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": {
          "tool_name": "Write"
        },
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint -- --fix $CLAUDE_FILE_PATH"
          }
        ]
      }
    ]
  }
}
```

### Matcher Options

> **Note**: The `//` comments are for illustration only. Remove them before use in `settings.json`.

```json
// Match by tool name
"matcher": { "tool_name": "bash" }

// Match by tool input content (regular expression)
"matcher": { "tool_input": ".*\\.prod\\..*" }

// Combined conditions (AND logic)
"matcher": {
  "tool_name": "Write",
  "tool_input": ".*\\.ts$"
}
```

### Hook Types

| Type | Behavior |
|------|----------|
| `"command"` | Execute a shell command |
| `"block"` | Prevent the tool from executing (PreToolUse only) |

---

## Hook Script Examples (bash)

### Auto-test on File Write

Run the test suite automatically every time a file is written:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": { "tool_name": "Write" },
        "hooks": [
          {
            "type": "command",
            "command": "npm test -- --passWithNoTests --bail 2>&1 | tail -20",
            "timeout": 60000
          }
        ]
      }
    ]
  }
}
```

The `timeout` field (in milliseconds) prevents the hook from blocking indefinitely.

### Auto-lint on TypeScript File Write

Run the linter only when `.ts` files are modified:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": { "tool_name": "Write", "tool_input": ".*\\.ts$" },
        "hooks": [
          {
            "type": "command",
            "command": "npx tsc --noEmit && npx eslint $CLAUDE_FILE_PATH --fix",
            "on_failure": "warn"
          }
        ]
      }
    ]
  }
}
```

### Run pytest on Python File Write

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": { "tool_name": "Write", "tool_input": ".*\\.py$" },
        "hooks": [
          {
            "type": "command",
            "command": "python -m pytest --tb=short -q 2>&1 | tail -30",
            "timeout": 120000
          }
        ]
      }
    ]
  }
}
```

---

## Blocking Dangerous Commands

Use `PreToolUse` hooks with `"type": "block"` to prevent harmful operations before they execute.

### Block Production Configuration File Changes

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": {
          "tool_name": "Write",
          "tool_input": ".*\\.(prod|production)\\.(env|json|yaml)$"
        },
        "hooks": [
          {
            "type": "block",
            "reason": "Direct modification of production config files is not allowed. Please go through the review process."
          }
        ]
      }
    ]
  }
}
```

### Block Dangerous Shell Commands

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": { "tool_name": "bash", "tool_input": ".*rm -rf.*" },
        "hooks": [
          {
            "type": "block",
            "reason": "Recursive force-delete commands are prohibited."
          }
        ]
      }
    ]
  }
}
```

### Enforce Code Quality Before git commit

Run linting and type checking before every commit; block the commit if checks fail:

```json
{
  "hooks": {
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
  }
}
```

---

## Notification Hooks (Slack / Desktop)

### Slack Notification on Session End

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "curl -s -X POST $SLACK_WEBHOOK_URL -H 'Content-type: application/json' -d '{\"text\": \"Claude Code session completed.\"}'"
          }
        ]
      }
    ]
  }
}
```

Set the `SLACK_WEBHOOK_URL` environment variable to your Slack Incoming Webhook URL.

### Desktop Notification (macOS)

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"$CLAUDE_NOTIFICATION_MESSAGE\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

### Desktop Notification (Linux)

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "notify-send 'Claude Code' \"$CLAUDE_NOTIFICATION_MESSAGE\""
          }
        ]
      }
    ]
  }
}
```

---

## Cost Tracking Log

Record token usage after every response:

```json
{
  "hooks": {
    "MessageStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo \"$(date -Iseconds) tokens=$CLAUDE_INPUT_TOKENS+$CLAUDE_OUTPUT_TOKENS\" >> ~/.claude/cost-log.txt"
          }
        ]
      }
    ]
  }
}
```

---

## Available Environment Variables

The following environment variables are available inside hook commands:

| Variable | Contents |
|----------|---------|
| `$CLAUDE_FILE_PATH` | Path of the file being operated on |
| `$CLAUDE_TOOL_NAME` | Name of the tool that was executed |
| `$CLAUDE_TOOL_INPUT` | Input value passed to the tool |
| `$CLAUDE_TOOL_OUTPUT` | Output value returned by the tool |
| `$CLAUDE_INPUT_TOKENS` | Number of input tokens used |
| `$CLAUDE_OUTPUT_TOKENS` | Number of output tokens used |
| `$CLAUDE_SESSION_ID` | Current session ID |
| `$CLAUDE_NOTIFICATION_MESSAGE` | Notification message text |
| `$CLAUDE_SUBAGENT_ID` | Subagent ID |
| `$CLAUDE_WORKING_DIRECTORY` | Current working directory |

---

## `on_failure` Options

The `on_failure` field controls what happens when a hook command exits with a non-zero status code:

> **Note**: The `//` comments are for illustration only. Remove them before use in `settings.json`.

```json
{
  "type": "command",
  "command": "npm test",
  "on_failure": "block"    // Block the tool from executing if this command fails
}
```

| Value | Behavior |
|-------|---------|
| `"block"` | Prevent the tool from executing (useful for PreToolUse gates) |
| `"warn"` | Display a warning but continue execution (default) |
| `"ignore"` | Silently continue even if the command fails |

---

## Triple Loop Hooks Example

A complete hooks configuration suitable for an autonomous Triple Loop development session:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": { "tool_name": "bash", "tool_input": ".*rm -rf.*" },
        "hooks": [{ "type": "block", "reason": "Dangerous commands are prohibited." }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": { "tool_name": "Write" },
        "hooks": [
          {
            "type": "command",
            "command": "echo \"[$(date '+%H:%M:%S')] File updated: $CLAUDE_FILE_PATH\" >> /tmp/claude-activity.log"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo '=== Loop completed ===' >> /tmp/claude-activity.log && git log --oneline -10 >> /tmp/claude-activity.log"
          }
        ]
      }
    ]
  }
}
```

---

## Related Documents

- [SettingsGuide.md](./SettingsGuide.md)
- [MCPGuide.md](./MCPGuide.md)
- [ArchitectureOverview.md](./ArchitectureOverview.md)
