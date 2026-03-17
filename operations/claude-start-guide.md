# Claude Start Guide

This guide explains how to start Claude Code for autonomous development sessions — from a simple one-loop run to a full three-loop autonomous system.

---

## Prerequisites

Before starting, ensure:

1. **Claude Code CLI installed**

   ```bash
   npm install -g @anthropic-ai/claude-code
   # or
   pip install claude-code
   ```

   Verify: `claude --version`

2. **API key configured**

   ```bash
   export ANTHROPIC_API_KEY="sk-ant-..."
   # or store in ~/.config/claude-code/config.json
   ```

3. **Repository access configured**

   ```bash
   # GitHub token for repository operations
   export GITHUB_TOKEN="ghp_..."
   ```

4. **State store directory created**

   ```bash
   mkdir -p .claude/state
   ```

---

## Starting Modes

### Mode 1: Interactive Session (Manual)

Run Claude Code interactively to handle a single task with full human oversight:

```bash
claude --interactive
```

This opens a chat interface. You describe the task, Claude implements it, and you approve each step.

**Best for:** Exploring Claude Code, one-off tasks, tasks requiring judgment calls.

---

### Mode 2: Single-Task Autonomous

Run Claude Code on a single task without interaction. The task is provided via a prompt file or argument:

```bash
claude --headless --task "Fix the failing unit tests in src/api/users.test.js"
```

Or using a prompt file:

```bash
claude --headless --prompt-file /tmp/task.txt
```

**Best for:** Automating a single known task, CI integration, scripted runs.

---

### Mode 3: Monitor Loop Only

Start just the Monitor loop to observe the repository and populate the work queue without implementing anything:

```bash
claude loop start monitor \
  --config .claude/config.yaml \
  --state-dir .claude/state
```

This is useful for:
- Auditing what the system would detect before enabling the Build loop
- Running the system in observation-only mode

---

### Mode 4: Full Three-Loop Autonomous System

Start all three loops as coordinated background processes:

```bash
claude loop start all \
  --config .claude/config.yaml \
  --state-dir .claude/state \
  --log-dir .claude/logs
```

This starts:
- Monitor loop (every 5 minutes by default)
- Build loop (continuous poll)
- Verify loop (every 10 minutes by default)

All three run as background daemons. See [Loop Command Usage](loop-command-usage.md) for how to manage them.

---

## Configuration File

The `--config` flag points to a YAML configuration file. Minimal example:

```yaml
# .claude/config.yaml

project:
  name: "my-project"
  repo: "org/repo"
  default_branch: "main"

loops:
  monitor:
    enabled: true
    interval_minutes: 5
    sources:
      github_issues: true
      ci_pipeline: true

  build:
    enabled: true
    max_retries: 2
    protected_paths:
      - ".github/workflows/**"
      - "*.env"

  verify:
    enabled: true
    interval_minutes: 10
    merge_strategy: "squash"

state_dir: ".claude/state"
log_dir: ".claude/logs"
```

See [Autonomous Development Workflow](autonomous-development-workflow.md) for full configuration options.

---

## First Run Checklist

Before starting the full autonomous system for the first time:

- [ ] Review and understand the [Triple Loop Architecture](../architecture/triple-loop-architecture.md)
- [ ] Configure `.claude/config.yaml` with your project settings
- [ ] Run Monitor loop only and review the generated work queue
- [ ] Verify the work items are appropriate and well-scoped
- [ ] Check that protected paths are correctly configured
- [ ] Enable Build loop — watch the first few cycles manually
- [ ] Enable Verify loop once you trust the Build loop output
- [ ] Set up alerting so you are notified of escalations

---

## System Prompt Files

Claude Code agents use system prompts to define their role. The default prompts are in this repository:

| Agent | Prompt file |
|---|---|
| Monitor | `prompts/monitor-loop-prompts.md` |
| Build | Use Claude Code defaults or customize |
| Verify | `prompts/verify-loop-prompts.md` |

To use a custom prompt:

```bash
claude loop start monitor \
  --system-prompt prompts/monitor-loop-prompts.md
```

---

## Logging and Output

By default, logs are written to `.claude/logs/`:

```
.claude/logs/
├── monitor-loop.log
├── build-loop.log
├── verify-loop.log
└── orchestrator.log
```

To follow logs in real time:

```bash
tail -f .claude/logs/build-loop.log
```

Or use the status command:

```bash
claude loop status
```

---

## Stopping the System

To stop all loops gracefully:

```bash
claude loop stop all
```

To stop a single loop:

```bash
claude loop stop monitor
```

Graceful stop waits for the current cycle to complete before exiting. Use `--force` to stop immediately:

```bash
claude loop stop all --force
```

---

## Environment Variables Reference

| Variable | Description | Required |
|---|---|---|
| `ANTHROPIC_API_KEY` | Anthropic API key for Claude | Yes |
| `GITHUB_TOKEN` | GitHub personal access token | Yes (for GitHub sources) |
| `CLAUDE_CONFIG_PATH` | Override default config file path | No |
| `CLAUDE_STATE_DIR` | Override default state directory | No |
| `CLAUDE_LOG_LEVEL` | Log level: `debug`, `info`, `warn`, `error` | No |
| `CLAUDE_MAX_COST_USD` | Abort if estimated API cost exceeds this | No |

---

## Related Documents

- [Loop Command Usage](loop-command-usage.md)
- [Autonomous Development Workflow](autonomous-development-workflow.md)
- [Triple Loop Architecture](../architecture/triple-loop-architecture.md)
- [Long Autonomous Sessions](../best-practices/long-autonomous-sessions.md)
