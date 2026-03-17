# Autonomous Development Workflow

This document describes the end-to-end workflow for a complete autonomous development cycle — from initial setup through ongoing operation.

---

## Workflow Overview

```
Phase 1: Setup
    └── Install, configure, verify environment

Phase 2: Observation (Monitor only)
    └── Start Monitor loop, review work queue
    └── Validate detected work items are correct

Phase 3: Implementation (Monitor + Build)
    └── Enable Build loop
    └── Watch first few cycles manually
    └── Tune configuration based on output quality

Phase 4: Full Autonomous (Monitor + Build + Verify)
    └── Enable Verify loop
    └── System runs fully autonomously
    └── Operator monitors via status, alerts, and audit log

Phase 5: Ongoing Operations
    └── Review metrics weekly
    └── Tune prompts based on rejection rate
    └── Update configuration as codebase evolves
```

---

## Phase 1: Setup

### 1.1 Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
claude --version  # Verify installation
```

### 1.2 Configure credentials

```bash
# Add to shell profile (~/.bashrc or ~/.zshrc)
export ANTHROPIC_API_KEY="sk-ant-..."
export GITHUB_TOKEN="ghp_..."
```

### 1.3 Initialize the project configuration

```bash
# Create the config directory
mkdir -p .claude/{state,logs}

# Generate a default config file
claude init --output .claude/config.yaml
```

### 1.4 Customize the config file

Edit `.claude/config.yaml`:

```yaml
project:
  name: "my-project"
  repo: "org/repo"
  default_branch: "main"

loops:
  monitor:
    enabled: true
    interval_minutes: 5
    sources:
      github_issues:
        enabled: true
        labels_to_watch: ["bug", "enhancement"]
      ci_pipeline:
        enabled: true
      code_coverage:
        enabled: true
        minimum_coverage: 80

  build:
    enabled: false          # Enable in Phase 3
    max_retries: 2
    max_files_per_change: 20
    protected_paths:
      - ".github/workflows/**"
      - "infrastructure/**"
      - "*.env"

  verify:
    enabled: false          # Enable in Phase 4
    interval_minutes: 10
    merge_strategy: "squash"
    require_ci_pass: true
    max_rejection_before_escalation: 3

alerts:
  slack_webhook: ""         # Optional - recommended for production use
  email: ""                 # Optional - recommended for production use
```

---

## Phase 2: Observation

### 2.1 Start the Monitor loop only

```bash
claude loop start monitor \
  --config .claude/config.yaml \
  --log-dir .claude/logs
```

### 2.2 Watch the work queue populate

```bash
# Check status every 30 seconds
claude loop status --watch

# Follow the monitor log
claude loop logs monitor --follow
```

### 2.3 Review generated work items

```bash
claude loop queue list
```

For each work item, verify:
- Is the type correct? (bug_fix, feature, test, etc.)
- Is the priority appropriate?
- Is the description clear enough for a Build agent to act on?
- Are the acceptance criteria specific and testable?

### 2.4 Adjust Monitor configuration

If work items are too vague or incorrect:
- Refine the Monitor prompt (see [Monitor Loop Prompts](../prompts/monitor-loop-prompts.md))
- Adjust source filters (labels, CI failure threshold)
- Update priority rules

Clear and restart:

```bash
claude loop stop monitor
claude loop queue clear --confirm
claude loop start monitor
```

---

## Phase 3: Implementation

### 3.1 Enable the Build loop

In `.claude/config.yaml`, set:

```yaml
loops:
  build:
    enabled: true
```

Restart:

```bash
claude loop stop all
claude loop start monitor
claude loop start build
```

### 3.2 Monitor first Build cycles closely

```bash
# Follow build loop log
claude loop logs build --follow
```

Watch for:
- Did the Build loop pick up the right work item?
- Did it explore the right files?
- Is the implementation reasonable?
- Did local checks (lint, tests) pass?
- Is the PR description clear and accurate?

### 3.3 Review PRs manually (Phase 3 only)

Before enabling the Verify loop, review the first several PRs manually on GitHub. Look for:
- Are the changes scoped correctly?
- Is the code quality acceptable?
- Are tests meaningful?
- Are commit messages clear?

Use this phase to tune the Build loop's configuration and prompts.

---

## Phase 4: Full Autonomous Operation

### 4.1 Enable the Verify loop

In `.claude/config.yaml`:

```yaml
loops:
  verify:
    enabled: true
```

Restart:

```bash
claude loop stop all
claude loop start all
```

### 4.2 Monitor the first Verify cycles

```bash
claude loop logs verify --follow
```

Watch for:
- Is the Verify loop catching real issues?
- Is the approval rate reasonable? (target: 70–90% first-pass approval)
- Are rejection reasons helpful and actionable?

### 4.3 Set up alerting

Configure Slack or email alerts in `.claude/config.yaml` to be notified of:
- Loop errors or restarts
- Work items escalated to human review
- Verify loop rejection rate exceeding threshold

---

## Phase 5: Ongoing Operations

### Daily

- Review `claude loop status` output
- Check for escalated items requiring human attention
- Review any merged PRs from the previous day

### Weekly

- Review metrics: work items completed, rejection rate, cycle time
- Review any persistent escalations
- Update protected paths if project structure changed
- Check API cost report

### Monthly

- Review and refine system prompts based on observed output quality
- Update configuration as codebase evolves
- Review and close old completed/rejected work items
- Audit merged changes for unexpected or undesirable patterns

---

## Handling Escalations

When a work item is escalated to `needs_human_review`:

```bash
# List escalated items
claude loop queue list --status needs_human_review
```

For each escalated item, you can:

```bash
# Approve and put back in queue with guidance
claude loop queue update WI-47 --status queued --comment "Scope the fix to users.js only"

# Reject and close the work item
claude loop queue update WI-47 --status closed --comment "Not a bug, expected behavior"

# Handle manually outside the system
claude loop queue update WI-47 --status manual --comment "Engineer handling directly"
```

---

## Pausing and Resuming

Pause all loops before a manual deployment:

```bash
claude loop pause all
# ... do your manual deployment ...
claude loop resume all
```

Pause just the Build loop while reviewing a sensitive area of the codebase:

```bash
claude loop pause build
# ... review ...
claude loop resume build
```

---

## Emergency Stop

If the system behaves unexpectedly:

```bash
# Immediate stop of all loops
claude loop stop all --force

# Review recent actions
claude loop logs all --lines 200

# Review recent state changes
cat .claude/state/audit.log | tail -50
```

Do not restart until you have identified and resolved the unexpected behavior.

---

## Full Configuration Reference

```yaml
project:
  name: string                     # Project display name
  repo: string                     # "owner/repo"
  default_branch: string           # Branch to merge to (default: "main")

loops:
  monitor:
    enabled: bool
    interval_minutes: int          # Default: 5
    sources:
      github_issues:
        enabled: bool
        labels_to_watch: [string]
      github_prs:
        enabled: bool
        stale_days: int
      ci_pipeline:
        enabled: bool
        failure_threshold: int     # Number of consecutive failures
      code_coverage:
        enabled: bool
        minimum_coverage: int      # Percent (0-100)

  build:
    enabled: bool
    max_retries: int               # Default: 2
    max_files_per_change: int      # Default: 20
    max_lines_per_change: int      # Default: 500
    protected_paths: [string]      # Glob patterns
    pr_labels: [string]
    pr_reviewers: [string]

  verify:
    enabled: bool
    interval_minutes: int          # Default: 10
    merge_strategy: string         # "squash" | "merge" | "rebase"
    delete_branch_after_merge: bool
    require_ci_pass: bool          # Default: true
    max_rejection_before_escalation: int  # Default: 3
    coverage_check:
      enabled: bool
      allow_decrease: bool
      minimum_coverage: int

state_dir: string                  # Default: ".claude/state"
log_dir: string                    # Default: ".claude/logs"
log_level: string                  # "debug" | "info" | "warn" | "error"

alerts:
  slack_webhook: string
  email: string
  on:
    - loop_error
    - loop_restart
    - escalation
    - high_rejection_rate
```

---

## Related Documents

- [Claude Start Guide](claude-start-guide.md)
- [Loop Command Usage](loop-command-usage.md)
- [Triple Loop Architecture](../architecture/triple-loop-architecture.md)
- [Long Autonomous Sessions](../best-practices/long-autonomous-sessions.md)
