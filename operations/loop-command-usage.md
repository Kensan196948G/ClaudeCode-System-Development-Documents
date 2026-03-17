# Loop Command Usage

This document is a reference for all `claude loop` CLI commands used to manage the three-loop autonomous development system.

---

## Command Overview

```
claude loop <command> [options]
```

| Command | Description |
|---|---|
| `start` | Start one or all loops |
| `stop` | Stop one or all loops |
| `status` | Show current status of all loops |
| `pause` | Pause a loop (keeps state, stops processing) |
| `resume` | Resume a paused loop |
| `logs` | View or follow loop logs |
| `queue` | Inspect or modify the work queue |
| `run-once` | Run a single cycle of a loop and exit |
| `reset` | Reset loop state (destructive) |

---

## `claude loop start`

Start one or all loops as background processes.

```bash
# Start all loops
claude loop start all

# Start a specific loop
claude loop start monitor
claude loop start build
claude loop start verify
```

### Options

| Flag | Description | Default |
|---|---|---|
| `--config <path>` | Path to config file | `.claude/config.yaml` |
| `--state-dir <path>` | Directory for state store | `.claude/state` |
| `--log-dir <path>` | Directory for log files | `.claude/logs` |
| `--system-prompt <path>` | Override system prompt file | Built-in default |
| `--dry-run` | Show what would run, don't execute | Off |
| `--foreground` | Run in foreground (don't daemonize) | Off |

### Examples

```bash
# Start all loops with custom config
claude loop start all --config ./config/prod.yaml

# Start monitor loop in foreground for debugging
claude loop start monitor --foreground

# Dry run — show what would happen without running
claude loop start all --dry-run
```

---

## `claude loop stop`

Stop one or all loops gracefully.

```bash
# Stop all loops
claude loop stop all

# Stop a specific loop
claude loop stop monitor
claude loop stop build
claude loop stop verify
```

### Options

| Flag | Description | Default |
|---|---|---|
| `--force` | Kill immediately without waiting for cycle completion | Off |
| `--timeout <seconds>` | Max wait time before forcing stop | 60 |

### Examples

```bash
# Graceful stop (waits for current cycle to complete)
claude loop stop all

# Force stop immediately
claude loop stop all --force

# Stop build loop, wait up to 2 minutes
claude loop stop build --timeout 120
```

---

## `claude loop status`

Show the current status of all loops and the work queue.

```bash
claude loop status
```

### Example output

```
╔══════════════════════════════════════════════════════════════╗
║                  Claude Loop Status                         ║
╠══════════════════════════════════════════════════════════════╣
║ Loop     │ Status   │ Last Heartbeat      │ Cycles │ Errors ║
╠══════════════════════════════════════════════════════════════╣
║ Monitor  │ running  │ 2025-01-15 10:25:00 │ 48     │ 0      ║
║ Build    │ running  │ 2025-01-15 10:26:10 │ 12     │ 1      ║
║ Verify   │ running  │ 2025-01-15 10:20:00 │ 8      │ 0      ║
╠══════════════════════════════════════════════════════════════╣
║ Work Queue: 3 items │ In Progress: 1 │ Pending Verify: 2   ║
╚══════════════════════════════════════════════════════════════╝
```

### Options

| Flag | Description |
|---|---|
| `--json` | Output as JSON |
| `--watch` | Refresh every 5 seconds |

---

## `claude loop pause`

Pause a loop. The loop stops at the end of its current cycle and waits. State is preserved.

```bash
claude loop pause all
claude loop pause build
```

**Use case:** Pausing before a manual deployment or during an incident.

---

## `claude loop resume`

Resume a paused loop.

```bash
claude loop resume all
claude loop resume build
```

---

## `claude loop logs`

View loop logs.

```bash
# Show last 100 lines of all loop logs
claude loop logs

# Follow a specific loop's log
claude loop logs build --follow

# Show logs with timestamps
claude loop logs monitor --timestamps

# Show only errors
claude loop logs verify --level error
```

### Options

| Flag | Description | Default |
|---|---|---|
| `--follow` / `-f` | Follow log output | Off |
| `--lines <n>` / `-n <n>` | Number of lines to show | 100 |
| `--level <level>` | Filter by log level | all |
| `--timestamps` | Include timestamps | Off |
| `--json` | Output raw JSON logs | Off |

---

## `claude loop queue`

Inspect and manage the work queue.

```bash
# List all items in the queue
claude loop queue list

# Show details of a specific work item
claude loop queue show WI-47

# Add a work item manually
claude loop queue add --type bug_fix --title "Fix login error" --priority high

# Remove a work item
claude loop queue remove WI-47

# Clear the entire queue (destructive)
claude loop queue clear --confirm
```

### `queue list` output

```
╔════════╦═══════════╦══════════╦════════════════════════════════╗
║ ID     ║ Type      ║ Priority ║ Title                          ║
╠════════╬═══════════╬══════════╬════════════════════════════════╣
║ WI-47  ║ bug_fix   ║ high     ║ API returns 500 on empty input ║
║ WI-48  ║ test      ║ medium   ║ Add tests for auth middleware   ║
║ WI-49  ║ docs      ║ low      ║ Update README setup section    ║
╚════════╩═══════════╩══════════╩════════════════════════════════╝
```

---

## `claude loop run-once`

Run a single cycle of a loop synchronously and exit. Useful for testing and debugging.

```bash
# Run one monitor cycle
claude loop run-once monitor

# Run one build cycle (processes one work item)
claude loop run-once build

# Run one verify cycle
claude loop run-once verify
```

### Options

| Flag | Description |
|---|---|
| `--dry-run` | Show what would happen, don't make changes |
| `--verbose` | Show detailed step-by-step output |
| `--work-item <id>` | (Build only) Force a specific work item |

### Example

```bash
# Dry run a single build cycle with verbose output
claude loop run-once build --dry-run --verbose
```

---

## `claude loop reset`

Reset loop state. **This is destructive and cannot be undone.**

```bash
# Reset all loop state (clears queue, history, etc.)
claude loop reset all --confirm

# Reset state for a single loop
claude loop reset monitor --confirm

# Reset only the work queue
claude loop reset queue --confirm
```

Always stop loops before resetting:

```bash
claude loop stop all && claude loop reset all --confirm
```

---

## Exit Codes

| Code | Meaning |
|---|---|
| 0 | Success |
| 1 | General error |
| 2 | Configuration error |
| 3 | Loop already running (for `start`) |
| 4 | Loop not running (for `stop`, `pause`) |
| 5 | State store error |

---

## Related Documents

- [Claude Start Guide](claude-start-guide.md)
- [Autonomous Development Workflow](autonomous-development-workflow.md)
- [Triple Loop Architecture](../architecture/triple-loop-architecture.md)
