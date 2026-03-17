# Monitor Loop

The Monitor loop is the observational layer of the autonomous development system. It continuously watches the system for conditions that require developer attention and converts those observations into structured **work items** for the Build loop to process.

---

## Role and Responsibilities

The Monitor loop's single responsibility is **observe and classify**. It never writes code, never modifies the repository (except appending to the work queue), and never makes implementation decisions.

**It does:**
- Scan GitHub issues, PRs, and CI results
- Evaluate system health metrics and logs
- Classify detected conditions by type and priority
- Emit structured work items to the shared queue
- Deduplicate — never create the same work item twice

**It does not:**
- Write, modify, or delete code
- Make judgments about how to fix a problem
- Approve or reject changes

---

## Trigger Sources

The Monitor loop can pull signal from multiple sources:

| Source | What it looks for |
|---|---|
| GitHub Issues | New open issues, issues with specific labels |
| GitHub PRs | Stale PRs, PRs failing CI, PRs awaiting review |
| CI Pipeline | Failed builds, failed test suites, flaky tests |
| Code coverage | Coverage drops below threshold |
| Error logs | New error patterns, increased error rates |
| Performance metrics | Latency regressions, throughput drops |
| Security scans | New CVEs in dependencies, new code scan alerts |
| Scheduled tasks | Periodic dependency updates, documentation audits |

---

## Work Item Types

The Monitor loop classifies each detected condition into a work item type:

| Type | Description | Example |
|---|---|---|
| `bug_fix` | A defect in the existing code | API returns wrong status code |
| `feature` | A new capability requested | Add CSV export to reports |
| `test` | Missing or failing test coverage | No test for error path |
| `refactor` | Code quality improvement | Extract duplicated logic |
| `dependency_update` | Outdated or vulnerable dependency | lodash has CVE |
| `documentation` | Missing or outdated docs | README missing setup steps |
| `ci_fix` | Broken build or test pipeline | CI fails on Node 20 |
| `security` | Security vulnerability to address | SQL injection risk |

---

## Work Item Schema

```json
{
  "id": "WI-{sequence_number}",
  "type": "bug_fix",
  "priority": "high",
  "title": "Short description of the work",
  "description": "Detailed description with full context",
  "source": "github_issue",
  "source_id": "GH-42",
  "source_url": "https://github.com/org/repo/issues/42",
  "acceptance_criteria": [
    "The bug is no longer reproducible",
    "A regression test is added"
  ],
  "labels": ["backend", "api"],
  "created_at": "2025-01-15T10:00:00Z",
  "created_by": "monitor-loop",
  "status": "queued"
}
```

### Priority Levels

| Priority | Description | Examples |
|---|---|---|
| `critical` | System is broken or data is at risk | Production crash, data loss bug |
| `high` | Significant impact, time-sensitive | Major feature bug, security CVE |
| `medium` | Moderate impact | Minor bug, test gap |
| `low` | Nice to have | Documentation, minor refactor |

---

## Monitor Loop Execution Cycle

```
Start cycle
    │
    ├── 1. Fetch signals from all sources
    │         └── GitHub API, CI API, metrics, logs
    │
    ├── 2. Evaluate each signal
    │         └── Is this already in the queue or completed?
    │         └── Does this meet the threshold to create a work item?
    │
    ├── 3. Classify and prioritize
    │         └── Assign type, priority, and acceptance criteria
    │
    ├── 4. Deduplicate
    │         └── Check existing work_queue and completed items
    │         └── Skip if already tracked
    │
    ├── 5. Emit work items
    │         └── Append new items to work_queue in State Store
    │
    └── 6. Sleep until next interval (default: 5 minutes)
```

---

## Deduplication

The Monitor loop maintains awareness of previously created work items to avoid creating duplicates. Before creating a new work item, it checks:

1. Is the source (`source` + `source_id`) already in the queue?
2. Is the source already in `in_progress` or `completed`?
3. Has this same work item been rejected recently (within a configurable window)?

If any check matches, the Monitor loop skips creation and logs a deduplication event.

---

## Configuration

```yaml
monitor:
  enabled: true
  interval_minutes: 5
  sources:
    github_issues:
      enabled: true
      labels_to_watch: ["bug", "enhancement", "needs-attention"]
    github_prs:
      enabled: true
      stale_days: 7
    ci_pipeline:
      enabled: true
      failure_threshold: 1
    code_coverage:
      enabled: true
      minimum_coverage: 80
    error_logs:
      enabled: false
      log_path: "/var/log/app/error.log"
  priority_rules:
    - match: { label: "security" }
      priority: critical
    - match: { type: "ci_fix" }
      priority: high
    - match: { label: "bug" }
      priority: medium
```

---

## Prompt Engineering Notes

The Monitor loop's Claude agent uses a system prompt that:

1. Defines the output format (JSON work item schema)
2. Instructs the agent to classify, not solve
3. Provides priority rules and type definitions
4. Includes deduplication logic instructions
5. Explicitly prohibits writing code or making implementation decisions

See [Monitor Loop Prompts](../prompts/monitor-loop-prompts.md) for the full prompt templates.

---

## Monitoring the Monitor

The Monitor loop itself should be observable:

- **Heartbeat:** The loop writes a heartbeat timestamp to the State Store every cycle
- **Work items created:** Count of work items created per cycle, per source
- **Deduplication rate:** How often a signal was skipped as a duplicate
- **Signal fetch errors:** Any API errors when fetching from sources

---

## Related Documents

- [Build Loop](build-loop.md)
- [Verify Loop](verify-loop.md)
- [Triple Loop Architecture](../architecture/triple-loop-architecture.md)
- [Monitor Loop Prompts](../prompts/monitor-loop-prompts.md)
