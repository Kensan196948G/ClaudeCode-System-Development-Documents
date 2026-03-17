# Autonomous Development Architecture

This document describes the high-level system architecture for running Claude Code as a fully autonomous software development agent — capable of detecting, implementing, testing, and shipping code changes without human intervention in each cycle.

---

## System Goals

The autonomous development system is designed to:

1. **Continuously improve** a software system by detecting and resolving issues automatically
2. **Maintain quality** by applying the same standards a human engineer would apply
3. **Stay observable** so engineers can audit, override, or redirect the system at any time
4. **Fail safely** by pausing and alerting rather than making destructive or uncertain changes

---

## High-Level Architecture

```
┌────────────────────────────────────────────────────────────────────┐
│                         Operator Interface                         │
│              (GitHub, CLI, Dashboard, Slack alerts)                │
└────────────────────────────────┬───────────────────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │     Orchestrator         │
                    │  (Loop Manager / Cron)   │
                    └────────────┬────────────┘
                                 │
          ┌──────────────────────┼──────────────────────┐
          │                      │                      │
   ┌──────▼──────┐        ┌──────▼──────┐       ┌──────▼──────┐
   │   MONITOR   │        │    BUILD    │       │   VERIFY    │
   │    LOOP     │        │    LOOP     │       │    LOOP     │
   └──────┬──────┘        └──────┬──────┘       └──────┬──────┘
          │                      │                      │
          └──────────────────────▼──────────────────────┘
                                 │
                    ┌────────────▼────────────┐
                    │       State Store        │
                    │   (work queue, history)  │
                    └────────────┬────────────┘
                                 │
          ┌──────────────────────┼──────────────────────┐
          │                      │                      │
   ┌──────▼──────┐        ┌──────▼──────┐       ┌──────▼──────┐
   │  Repository │        │  CI / Tests │       │  Deployment │
   │   (GitHub)  │        │  Pipeline   │       │  Platform   │
   └─────────────┘        └─────────────┘       └─────────────┘
```

---

## Components

### Orchestrator

The Orchestrator is responsible for starting, stopping, and monitoring the three loops. It:

- Launches each loop process at system startup
- Monitors loop health (last heartbeat, error count)
- Restarts crashed loops with back-off
- Exposes a control API for human operators
- Surfaces loop status to dashboards and alerting systems

### State Store

The State Store is the single source of truth for the system's current status. All three loops read from and write to it. It holds:

| Field | Description |
|---|---|
| `work_queue` | Ordered list of pending work items |
| `in_progress` | Work item currently being processed by Build |
| `pending_verification` | Changes awaiting Verify loop review |
| `completed` | Successfully merged or deployed changes |
| `rejected` | Changes rejected by Verify, with reasons |
| `loop_status` | Current status and heartbeat of each loop |

The State Store is designed to be:
- **Atomic** — writes are transactional, preventing race conditions
- **Durable** — persisted to disk so restarts don't lose state
- **Auditable** — all state transitions are logged with timestamps

### Claude Code Agent

Each loop runs one or more **Claude Code agents** — instances of Claude Code configured with a specific system prompt that defines the agent's role and constraints.

Each agent:
- Receives a task as a structured prompt
- Reads files and tools as needed
- Produces a structured output (work item, code change, or review decision)
- Has no persistent memory between runs (stateless per invocation)

See [Agent Teams System](agent-teams-system.md) for multi-agent configurations.

---

## Data Flow

### 1. Monitor → Build

```
Monitor Loop
  → Reads: repository state, CI results, issue tracker
  → Produces: WorkItem { id, type, description, priority, context }
  → Writes to: state_store.work_queue
```

### 2. Build → Verify

```
Build Loop
  → Reads: state_store.work_queue (dequeues next item)
  → Produces: CodeChange { id, work_item_id, diff, tests_passed, summary }
  → Writes to: state_store.pending_verification
  → Writes to: repository (branch or PR)
```

### 3. Verify → Done

```
Verify Loop
  → Reads: state_store.pending_verification
  → Produces: VerifyResult { change_id, decision, comments }
  → On approval: merges change, moves to state_store.completed
  → On rejection: returns to state_store.work_queue with comments
```

---

## Security Model

### Principle of Least Privilege

Each loop agent is given only the permissions it needs:

| Loop | Repository access | CI access | Deployment access |
|---|---|---|---|
| Monitor | Read-only | Read-only | None |
| Build | Read + Write (feature branch) | Read | None |
| Verify | Read + Merge (to main) | Read + Trigger | Optional |

### Change Scope Limits

The Build loop enforces **change scope limits** to prevent unbounded modifications:

- Maximum files changed per work item: configurable (default: 20)
- Maximum lines changed per work item: configurable (default: 500)
- Changes exceeding limits are split or escalated to human review

### Sensitive File Protection

A configurable list of **protected paths** cannot be modified by the Build loop without explicit operator approval. Typical protected paths:

```
.github/workflows/**
infrastructure/**
secrets/**
*.env
```

---

## Failure Modes and Recovery

| Failure | Detection | Recovery |
|---|---|---|
| Loop crashes | Heartbeat timeout | Auto-restart with back-off |
| Work item stuck in progress | Age threshold exceeded | Return to queue, alert operator |
| Build loop produces bad code | Verify loop rejects | Return to queue with rejection reason |
| Verify loop rejects repeatedly | Rejection count threshold | Escalate to human review |
| State store corrupted | Schema validation on read | Restore from last checkpoint |
| Repository API unavailable | API error response | Retry with back-off, pause loops |

---

## Observability

### Logs

Every loop emits structured JSON logs:

```json
{
  "timestamp": "2025-01-15T10:23:00Z",
  "loop": "monitor",
  "event": "work_item_created",
  "work_item_id": "WI-47",
  "type": "bug_fix",
  "source": "github_issue",
  "source_id": "GH-123"
}
```

### Metrics

Key metrics exposed per loop:

- Work items created / resolved per hour
- Build loop cycle time (detect → merge)
- Verify approval rate
- Loop error rate and restart count
- Queue depth

---

## Related Documents

- [Triple Loop Architecture](triple-loop-architecture.md)
- [Agent Teams System](agent-teams-system.md)
- [Autonomous Development Workflow](../operations/autonomous-development-workflow.md)
- [Long Autonomous Sessions](../best-practices/long-autonomous-sessions.md)
