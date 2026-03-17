# Triple Loop Architecture

The Triple Loop architecture is the core design pattern that enables Claude Code to operate as a fully autonomous software development system. It consists of three tightly coordinated loops — **Monitor**, **Build**, and **Verify** — each with a distinct role in the continuous development cycle.

---

## Overview

```
┌──────────────────────────────────────────────────────────┐
│                  Autonomous Dev System                   │
│                                                          │
│   ┌─────────────┐   signals   ┌─────────────┐           │
│   │   MONITOR   │ ──────────> │    BUILD    │           │
│   │    LOOP     │             │    LOOP     │           │
│   └──────┬──────┘             └──────┬──────┘           │
│          │                           │                  │
│          │ observes                  │ produces         │
│          ▼                           ▼                  │
│   ┌─────────────┐             ┌─────────────┐           │
│   │   System    │             │   VERIFY    │           │
│   │   State     │ <────────── │    LOOP     │           │
│   └─────────────┘  validates  └─────────────┘           │
└──────────────────────────────────────────────────────────┘
```

The three loops run as separate, coordinated processes:

| Loop | Primary Role | Trigger | Output |
|---|---|---|---|
| Monitor | Observe & detect | Time-based / event-based | Work items / alerts |
| Build | Implement | Work item from Monitor | Code changes |
| Verify | Validate | Change from Build | Approval / rejection |

---

## The Monitor Loop

The Monitor loop continuously watches the system for conditions that require work. It does not write code — its sole job is observation and classification.

### What it monitors

- Repository state (unresolved issues, failing tests, open PRs)
- System health metrics (error rates, performance regressions)
- External triggers (new GitHub issues, scheduled tasks)
- Build and test pipeline results

### How it signals

When the Monitor loop detects a condition requiring work, it emits a **work item** — a structured description of what needs to be done. This is placed into a shared work queue that the Build loop consumes.

See [Monitor Loop](../loops/monitor-loop.md) for detailed documentation.

---

## The Build Loop

The Build loop is the development engine. It reads work items from the queue, plans implementation steps, writes code, and submits changes.

### What it does

1. Dequeues the next work item
2. Analyzes the codebase to understand context
3. Plans and implements the required change
4. Runs local checks (lint, unit tests)
5. Submits the change (commit, PR, or patch)
6. Marks the work item as pending verification

### Key characteristics

- Each Build cycle handles **one work item at a time** to maintain traceability
- Build loop includes self-correction: if a local check fails, it retries before submitting
- Changes are always atomic and scoped to the work item

See [Build Loop](../loops/build-loop.md) for detailed documentation.

---

## The Verify Loop

The Verify loop is the quality gate. It reviews changes produced by the Build loop using a different perspective than the one that produced the code.

### What it does

1. Picks up a submitted change awaiting verification
2. Reviews the change for correctness, completeness, and safety
3. Runs integration tests and any additional quality checks
4. Approves (merge/deploy) or rejects (return to Build queue)

### Why a separate loop?

Separating verification from building provides:

- **Independent perspective** — the verifier evaluates with fresh context
- **Scalability** — verification can be parallelized across changes
- **Safety** — a single compromised Build cycle cannot auto-approve its own changes

See [Verify Loop](../loops/verify-loop.md) for detailed documentation.

---

## Loop Coordination

### Shared State

All three loops share a lightweight **state store** (typically a JSON file or a small database) that contains:

```json
{
  "work_queue": [],
  "in_progress": [],
  "pending_verification": [],
  "completed": [],
  "rejected": []
}
```

### Timing

Loops are not synchronous with each other. They each run on their own schedule:

| Loop | Default interval | Configurable |
|---|---|---|
| Monitor | Every 5 minutes | Yes |
| Build | Continuous (poll) | Yes |
| Verify | Every 10 minutes | Yes |

### Error Handling

If any loop throws an unhandled error:
1. The error is logged with full context
2. The loop restarts after a configurable back-off delay
3. If a loop restarts more than N times within a window, it enters a **paused** state and alerts the operator

---

## Design Principles

### 1. Single Responsibility

Each loop has one job. The Monitor loop does not write code. The Build loop does not approve its own output. The Verify loop does not produce new work items.

### 2. Idempotency

Every work item has a unique ID. Loops check for duplicate processing before acting, so a restart never produces duplicate changes.

### 3. Observability

Every action each loop takes is logged with structured data:

```json
{
  "loop": "build",
  "action": "implement",
  "work_item_id": "WI-42",
  "timestamp": "2025-01-15T10:23:00Z",
  "status": "success",
  "duration_ms": 4521
}
```

### 4. Human Override

At any point, a human operator can:
- Pause any or all loops
- Reject a work item manually
- Insert a work item directly into the queue
- Override a Verify loop decision

---

## Related Documents

- [Autonomous Development Architecture](autonomous-development-architecture.md)
- [Agent Teams System](agent-teams-system.md)
- [Monitor Loop](../loops/monitor-loop.md)
- [Build Loop](../loops/build-loop.md)
- [Verify Loop](../loops/verify-loop.md)
