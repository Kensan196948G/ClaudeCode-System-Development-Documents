# Agent Teams System

The Agent Teams system organizes multiple Claude Code agents into specialized roles, enabling concurrent and scalable autonomous development. Instead of one monolithic agent handling everything, each agent is focused, prompt-engineered, and coordinated through shared state.

---

## Why Agent Teams?

A single agent running all tasks sequentially has limitations:

- **Context window saturation** — long-running tasks fill the context, degrading quality
- **No separation of concerns** — the same agent that writes code also approves it
- **No parallelism** — only one task runs at a time
- **Single point of failure** — one crash stops everything

Agent teams address each of these by assigning roles and coordinating through a shared state store.

---

## Team Structure

```
┌─────────────────────────────────────────────────────────┐
│                      Agent Teams                        │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │               Orchestrator Agent                  │  │
│  │        (coordinates, routes, escalates)           │  │
│  └──────────────────┬───────────────────────────────┘  │
│                     │                                   │
│    ┌────────────────┼────────────────┐                  │
│    │                │                │                  │
│  ┌─▼──────────┐  ┌──▼─────────┐  ┌──▼─────────┐       │
│  │  Monitor   │  │   Build    │  │   Verify   │       │
│  │  Agent(s)  │  │  Agent(s)  │  │  Agent(s)  │       │
│  └────────────┘  └────────────┘  └────────────┘       │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │              Specialist Agents (optional)         │  │
│  │   Security | Performance | Documentation | Test   │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

---

## Core Agent Roles

### Orchestrator Agent

The Orchestrator is responsible for the health of the whole team. It:

- Starts and monitors all other agents
- Routes work items to the appropriate agent type
- Escalates work items that exceed confidence thresholds
- Sends alerts when loops stall or fail
- Produces a status report on request

**System prompt focus:** Coordination, routing, health checks, reporting.

**Does not:** Write code, review code, or modify the repository.

---

### Monitor Agent

The Monitor agent continuously observes the system and creates work items.

**Responsibilities:**
- Scan open GitHub issues and PRs
- Check CI/CD pipeline results
- Review system logs and error rates
- Evaluate test coverage and failure trends
- Classify and prioritize detected work

**Output:**
```json
{
  "id": "WI-47",
  "type": "bug_fix",
  "priority": "high",
  "title": "API endpoint returns 500 on empty input",
  "source": "github_issue",
  "source_id": "GH-123",
  "context": "The /api/users endpoint fails when the request body is empty...",
  "acceptance_criteria": ["Returns 400 with clear error message", "Unit test added"]
}
```

**Multiple instances:** Multiple Monitor agents can run concurrently, each watching a different domain (e.g., one for frontend issues, one for backend, one for infrastructure).

---

### Build Agent

The Build agent is the implementation engine.

**Responsibilities:**
- Read and understand the work item
- Explore the codebase to gather context
- Plan the implementation approach
- Write code, tests, and documentation
- Run local validation (lint, unit tests)
- Submit a pull request or commit

**Output:**
```json
{
  "id": "CH-33",
  "work_item_id": "WI-47",
  "branch": "fix/api-empty-input-WI-47",
  "pr_number": 88,
  "files_changed": ["src/api/users.js", "tests/api/users.test.js"],
  "summary": "Added input validation and a unit test for empty body case",
  "local_checks": "passed"
}
```

**Parallelism:** Multiple Build agents can work on different work items concurrently. Each agent is assigned a unique work item to prevent conflicts.

---

### Verify Agent

The Verify agent is the independent quality gate.

**Responsibilities:**
- Review the diff and implementation against the work item
- Check that acceptance criteria are met
- Evaluate code quality, security, and correctness
- Run or trigger integration tests
- Approve (merge) or reject (return with comments)

**Output:**
```json
{
  "change_id": "CH-33",
  "decision": "approved",
  "comments": "Implementation looks correct, test added, input validated.",
  "checks_run": ["unit_tests", "lint", "security_scan"],
  "checks_passed": true
}
```

**Key constraint:** The Verify agent is configured with a system prompt that explicitly prevents it from approving its own work.

---

## Specialist Agents (Optional)

For larger projects or higher-confidence requirements, specialist agents can be added to the team.

### Security Agent

- Reviews changes for known vulnerability patterns (injection, auth bypass, etc.)
- Scans dependencies for CVEs
- Flags changes that touch authentication, authorization, or cryptography for human review
- Runs as part of the Verify phase for security-sensitive changes

### Performance Agent

- Profiles critical paths in proposed changes
- Flags regressions in benchmarks
- Suggests optimizations

### Documentation Agent

- Keeps README files, API docs, and changelogs up to date
- Creates work items when documentation is missing or outdated
- Reviews that new code has appropriate inline comments

### Test Agent

- Evaluates test coverage for new code
- Writes additional tests when coverage is below threshold
- Identifies flaky tests and creates work items to fix them

---

## Agent Communication

Agents do not communicate directly. All coordination is through the **State Store**.

```
Monitor Agent    → writes work_queue
Build Agent      → reads work_queue, writes pending_verification + branch
Verify Agent     → reads pending_verification, writes completed or work_queue (reject)
Orchestrator     → reads all, writes loop_status
```

This decoupled design means:
- Agents can be restarted independently
- New agent types can be added without changing existing agents
- The full history is available for auditing

---

## Agent Configuration

Each agent is configured via:

1. **System prompt** — defines role, constraints, output format
2. **Tool access** — specific CLI tools and API access the agent can use
3. **Context limit** — maximum tokens per invocation
4. **Retry policy** — how many times to retry before escalating

Example agent config:

```yaml
agents:
  monitor:
    system_prompt: prompts/monitor-loop-prompts.md
    tools:
      - github_api
      - read_files
    interval_minutes: 5
    max_retries: 3

  build:
    system_prompt: prompts/build-agent-prompts.md
    tools:
      - github_api
      - read_files
      - write_files
      - run_tests
      - run_lint
    max_retries: 2

  verify:
    system_prompt: prompts/verify-loop-prompts.md
    tools:
      - github_api
      - read_files
      - run_tests
      - merge_pr
    interval_minutes: 10
    max_retries: 2
```

---

## Scaling the Team

| Team size | Recommended configuration |
|---|---|
| Small project | 1 Monitor + 1 Build + 1 Verify |
| Medium project | 1 Monitor + 2-3 Build (parallel) + 1 Verify |
| Large project | 2+ Monitor (by domain) + 4+ Build + 2 Verify + specialists |

---

## Related Documents

- [Triple Loop Architecture](triple-loop-architecture.md)
- [Autonomous Development Architecture](autonomous-development-architecture.md)
- [Monitor Loop](../loops/monitor-loop.md)
- [Build Loop](../loops/build-loop.md)
- [Verify Loop](../loops/verify-loop.md)
