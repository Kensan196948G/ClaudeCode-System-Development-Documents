# Build Loop

The Build loop is the implementation engine of the autonomous development system. It dequeues work items from the shared state, explores the codebase, writes code, runs checks, and submits changes for verification.

---

## Role and Responsibilities

The Build loop's single responsibility is **implement**. It takes a clearly defined work item and produces a corresponding code change that meets the stated acceptance criteria.

**It does:**
- Dequeue the highest-priority work item from the queue
- Explore the codebase to understand context
- Plan and implement the required change
- Write unit tests for new behavior
- Run lint and tests locally
- Submit the change (branch + PR or commit)
- Report the result to the State Store

**It does not:**
- Create new work items (that is the Monitor loop's job)
- Approve or merge its own changes (that is the Verify loop's job)
- Modify protected files without operator approval

---

## Build Loop Execution Cycle

```
Start cycle
    │
    ├── 1. Poll work_queue for next item
    │         └── Select highest-priority queued item
    │         └── Move item to `in_progress`
    │
    ├── 2. Explore codebase
    │         └── Read relevant files and documentation
    │         └── Understand existing patterns and conventions
    │
    ├── 3. Plan implementation
    │         └── Identify files to change
    │         └── Outline approach
    │
    ├── 4. Implement changes
    │         └── Write or modify source files
    │         └── Write or update tests
    │         └── Update documentation if needed
    │
    ├── 5. Run local validation
    │         └── Lint (must pass)
    │         └── Unit tests (must pass)
    │         └── If validation fails → retry up to N times → escalate
    │
    ├── 6. Submit change
    │         └── Create branch: fix/{type}-{work_item_id}
    │         └── Commit with structured message
    │         └── Open pull request
    │
    └── 7. Update State Store
              └── Move work item to `pending_verification`
              └── Record change details (branch, PR number, summary)
```

---

## Branch and Commit Naming

### Branch naming

```
{type}/{short-description}-{work-item-id}

Examples:
  fix/api-empty-input-WI-47
  feature/csv-export-WI-52
  test/missing-auth-tests-WI-55
  chore/update-lodash-WI-61
```

### Commit message format

```
{type}({scope}): {short description}

{body - what was done and why}

Resolves: WI-{id}
Source: {source_url}
```

Example:

```
fix(api): return 400 on empty request body

The /api/users endpoint was throwing a 500 when the request body
was empty or missing the required fields. Added input validation
using the existing validateBody helper and updated the error handler
to return a 400 with a descriptive message.

Added a unit test to cover the empty body case.

Resolves: WI-47
Source: https://github.com/org/repo/issues/42
```

---

## Change Scope Rules

To maintain traceability and reviewability, each Build cycle enforces scope limits:

| Constraint | Default | Description |
|---|---|---|
| Max files changed | 20 | If more files need changing, split the work item |
| Max lines changed | 500 | Large changes are split or escalated |
| Protected files | See config | Require explicit operator approval to modify |
| Single work item | 1 per cycle | Each cycle processes exactly one work item |

If a work item would require changes exceeding these limits, the Build loop:
1. Logs a scope exceeded event
2. Moves the work item to a `needs_human_review` state
3. Alerts the operator

---

## Self-Correction

If local validation (lint or tests) fails, the Build loop attempts to fix the failure before escalating:

```
Validation fails
    │
    ├── Attempt 1: Read error output, identify issue, patch
    │         └── Re-run validation
    │
    ├── Attempt 2: Broader context gathering + rethink approach
    │         └── Re-run validation
    │
    └── Attempt 3 (final): Log failure in detail
              └── Move work item back to work_queue with context
              └── Increment work item retry count
              └── If retry count > threshold → escalate to human review
```

---

## Pull Request Format

The Build loop opens a pull request for each change with a structured body:

```markdown
## Summary

{Description of what was changed and why}

## Work Item

- **ID:** WI-47
- **Type:** bug_fix
- **Source:** [GH-42](https://github.com/org/repo/issues/42)

## Changes Made

- `src/api/users.js`: Added input validation
- `tests/api/users.test.js`: Added test for empty body case

## Acceptance Criteria

- [x] The bug is no longer reproducible
- [x] A regression test is added

## Local Checks

- [x] Lint: passed
- [x] Unit tests: passed

---
*This PR was created by the Build Loop (autonomous). Review by Verify Loop pending.*
```

---

## Code Quality Standards

The Build loop is configured to follow the repository's own conventions. It checks:

- Existing code style (indentation, naming, patterns)
- Whether the project uses TypeScript, JSDoc, or other typing
- Test file co-location and naming patterns
- Import ordering and module structure

The Build loop reads the repository's configuration files (`.eslintrc`, `pyproject.toml`, etc.) and applies the same rules a human contributor would follow.

---

## Error States

| State | Trigger | Recovery |
|---|---|---|
| `validation_failed` | Lint or tests fail after max retries | Return to queue with error context |
| `scope_exceeded` | Change would exceed file/line limits | Escalate to human review |
| `conflict` | Branch conflicts with main | Rebase and retry, or escalate |
| `protected_file` | Change requires protected file modification | Escalate to human review |
| `no_work` | Work queue is empty | Sleep and poll again |

---

## Configuration

```yaml
build:
  enabled: true
  max_files_per_change: 20
  max_lines_per_change: 500
  max_retries: 2
  protected_paths:
    - ".github/workflows/**"
    - "infrastructure/**"
    - "*.env"
    - "secrets/**"
  branch_prefix: "auto/"
  pr_reviewers: []
  pr_labels: ["autonomous", "needs-verify"]
```

---

## Related Documents

- [Monitor Loop](monitor-loop.md)
- [Verify Loop](verify-loop.md)
- [Triple Loop Architecture](../architecture/triple-loop-architecture.md)
- [Autonomous Development Workflow](../operations/autonomous-development-workflow.md)
