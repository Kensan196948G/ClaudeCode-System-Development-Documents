# Verify Loop

The Verify loop is the quality gate of the autonomous development system. It independently reviews changes produced by the Build loop, checking that they meet the acceptance criteria of the original work item and that the implementation is correct, complete, and safe to merge.

---

## Role and Responsibilities

The Verify loop's single responsibility is **validate**. It reviews a change with fresh context — without being the agent that wrote it — and makes an explicit approve or reject decision.

**It does:**
- Review the code diff against the work item's acceptance criteria
- Evaluate correctness, completeness, and code quality
- Run or trigger automated tests (unit, integration, security)
- Approve changes that meet quality standards (trigger merge)
- Reject changes that do not (return to Build queue with comments)
- Log all decisions with full rationale

**It does not:**
- Write or modify code
- Create new work items
- Approve changes it authored (enforced by system prompt)

---

## Verify Loop Execution Cycle

```
Start cycle
    │
    ├── 1. Poll `pending_verification` for next change
    │         └── Select oldest change awaiting verification
    │
    ├── 2. Load context
    │         └── Read the original work item
    │         └── Read the PR diff and description
    │         └── Read changed files in full
    │
    ├── 3. Verify acceptance criteria
    │         └── For each acceptance criterion: pass / fail / unclear
    │
    ├── 4. Run automated checks
    │         └── Trigger CI if not already run
    │         └── Wait for CI result
    │         └── Check test coverage delta
    │
    ├── 5. Code quality review
    │         └── Correctness: does it do what it claims?
    │         └── Completeness: are there obvious gaps?
    │         └── Safety: any security or data risks?
    │         └── Style: does it match codebase conventions?
    │
    ├── 6. Make decision
    │         └── approved → merge PR, move to `completed`
    │         └── rejected → move back to `work_queue` with comments
    │
    └── 7. Update State Store
              └── Record decision, comments, checks run
              └── Update work item status
```

---

## Verification Checklist

For every change, the Verify loop checks:

### Functional Correctness

- [ ] The change addresses the stated problem or feature
- [ ] Each acceptance criterion is met
- [ ] Edge cases are handled (null inputs, empty collections, boundary values)
- [ ] Error handling is appropriate

### Test Coverage

- [ ] New behavior is covered by automated tests
- [ ] Tests are meaningful (test behavior, not just coverage)
- [ ] No existing tests were deleted without justification
- [ ] Tests pass in CI

### Code Quality

- [ ] Code follows existing patterns and conventions
- [ ] No obvious duplication introduced
- [ ] Naming is clear and consistent
- [ ] Logic is readable without needing a comment to explain intent

### Safety

- [ ] No sensitive data (credentials, secrets, PII) introduced
- [ ] No new external dependencies without justification
- [ ] Protected paths were not modified without approval
- [ ] Change scope is within configured limits

---

## Decision Outcomes

### Approved

When all checks pass, the Verify loop:

1. Approves the pull request via the GitHub API
2. Merges the PR (squash merge by default)
3. Deletes the feature branch
4. Moves the work item to `completed` in the State Store
5. Logs the approval with all check results

### Rejected

When one or more checks fail, the Verify loop:

1. Posts a detailed review comment on the PR explaining the failure
2. Requests changes (does not close the PR)
3. Moves the work item back to `work_queue` with the rejection reason appended
4. Increments the work item's rejection count
5. If rejection count exceeds threshold → escalates to human review

---

## Rejection Comments Format

Rejection comments are structured and actionable:

```markdown
## Verify Loop Review — Rejected

**Decision:** Rejected ❌
**Reviewer:** Verify Loop (autonomous)
**Timestamp:** 2025-01-15T12:30:00Z

### Failures

**Acceptance Criteria:**
- [ ] A regression test is added — *No test found for the empty body case*

**Code Quality:**
- ⚠️ `src/api/users.js:45` — error message is not user-friendly: `"err"` should be a descriptive string

### Passed Checks

- [x] Lint: passed
- [x] Unit tests: passed (existing tests)
- [x] No protected files modified
- [x] Change scope within limits

### Next Steps

The Build loop will pick this work item up again. The rejection reason above
has been appended to the work item context for the next implementation attempt.
```

---

## Escalation Policy

| Condition | Action |
|---|---|
| Rejection count > 3 | Move to `needs_human_review`, notify operator |
| CI unavailable | Pause Verify, alert operator, retry after back-off |
| Change modifies protected path | Move to `needs_human_review` immediately |
| Ambiguous acceptance criteria | Move to `needs_human_review`, ask operator for clarification |
| Security concern identified | Move to `needs_human_review`, create security work item |

---

## Running Tests

The Verify loop can trigger or read from CI, depending on configuration:

```yaml
verify:
  test_execution:
    mode: "ci"            # "ci" | "local" | "both"
    ci_wait_timeout_min: 30
    require_ci_pass: true
    coverage_check:
      enabled: true
      allow_decrease: false
      minimum_coverage: 80
```

- **`ci` mode:** Wait for the existing CI pipeline to complete and read the result
- **`local` mode:** Run tests locally inside the agent environment
- **`both` mode:** Run locally for fast feedback, then wait for CI before approving

---

## Verify Agent Prompt Constraints

The Verify agent's system prompt includes explicit constraints to ensure integrity:

1. **Cannot approve its own work** — The prompt includes the Build agent's identifier; if the change was produced by the same session, it must escalate
2. **Must justify decisions** — Every approved and rejected change includes a written rationale
3. **No code writing** — The Verify agent is configured with read-only file tools
4. **Conservative on ambiguity** — When in doubt, reject and ask for clarification rather than approving uncertain changes

See [Verify Loop Prompts](../prompts/verify-loop-prompts.md) for the full prompt templates.

---

## Configuration

```yaml
verify:
  enabled: true
  interval_minutes: 10
  max_rejection_before_escalation: 3
  merge_strategy: "squash"
  delete_branch_after_merge: true
  required_checks:
    - lint
    - unit_tests
    - ci_pipeline
  optional_checks:
    - security_scan
    - coverage
  escalation_notify:
    - slack: "#dev-alerts"
    - email: "team@example.com"
```

---

## Related Documents

- [Monitor Loop](monitor-loop.md)
- [Build Loop](build-loop.md)
- [Triple Loop Architecture](../architecture/triple-loop-architecture.md)
- [Verify Loop Prompts](../prompts/verify-loop-prompts.md)
- [Autonomous Development Workflow](../operations/autonomous-development-workflow.md)
