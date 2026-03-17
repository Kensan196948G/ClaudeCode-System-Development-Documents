# Best Practices for Long Autonomous Sessions

Running Claude Code in a fully autonomous loop for hours or days introduces unique operational challenges. This document covers best practices for keeping long sessions stable, productive, and safe.

---

## 1. Start Conservatively, Scale Gradually

Never launch all three loops at full speed against a production repository on day one.

### Recommended ramp-up sequence

| Phase | Duration | What to enable |
|---|---|---|
| 1. Observation | 1–2 days | Monitor loop only |
| 2. Manual review | 2–3 days | Monitor + Build, human reviews all PRs |
| 3. Assisted verify | 2–3 days | All three loops, human spot-checks PRs |
| 4. Full autonomous | Ongoing | All three loops, alerts for escalations |

This ramp-up lets you:
- Validate that work items are correctly classified
- Verify that Build loop output meets your quality bar
- Build confidence in the Verify loop before trusting it to auto-merge

---

## 2. Define Clear Protected Paths

The most important safety control is a well-defined list of paths the Build loop cannot touch without human approval.

At minimum, protect:

```yaml
protected_paths:
  - ".github/workflows/**"    # CI/CD pipeline definitions
  - "infrastructure/**"       # IaC (Terraform, CloudFormation, etc.)
  - "*.env"                   # Environment config
  - ".env*"
  - "secrets/**"
  - "**/config/production.*"
  - "Dockerfile"
  - "docker-compose.yml"
  - "CODEOWNERS"
  - "package-lock.json"       # Dependency lockfiles (review separately)
  - "yarn.lock"
  - "Pipfile.lock"
```

Review and update this list as your project evolves.

---

## 3. Set API Cost Limits

Long autonomous sessions consume significant API tokens. Set a hard cost limit to prevent runaway costs:

```bash
export CLAUDE_MAX_COST_USD=50
```

Or in config:

```yaml
limits:
  max_api_cost_usd_per_day: 50
  max_api_cost_usd_total: 200
  alert_at_cost_usd: 40
```

When the limit is reached, the system pauses all loops and sends an alert.

Monitor actual costs by reviewing the usage log:

```bash
cat .claude/logs/api-usage.log | tail -20
```

---

## 4. Configure Meaningful Alerts

You should be notified immediately when:

- Any loop crashes or restarts
- A work item is escalated to human review
- The Verify loop rejection rate exceeds 50% over a 1-hour window
- The API cost limit is approaching
- The work queue depth exceeds a threshold (possible runaway detection)
- A change touches a security-sensitive path

Recommended alert config:

```yaml
alerts:
  slack_webhook: "https://hooks.slack.com/..."
  on:
    - event: loop_restart
      severity: warning
    - event: escalation
      severity: warning
    - event: high_rejection_rate
      threshold_percent: 50
      window_minutes: 60
      severity: warning
    - event: cost_threshold
      threshold_usd: 40
      severity: warning
    - event: queue_depth_high
      threshold: 20
      severity: info
```

---

## 5. Keep Work Items Well-Scoped

Autonomous systems work best on small, clearly scoped work items. Large or ambiguous items cause:

- Build loop context window saturation
- Imprecise implementations
- High Verify rejection rates
- Cascading retries

### Signs a work item is too large

- Description is more than 200 words
- More than 5 acceptance criteria
- Implementation would require changes to more than 5 files
- The item combines multiple distinct problems

### What to do

If the Monitor loop is producing oversized work items:
- Refine the Monitor prompt to split large items
- Add a max-size rule to the Monitor's classification logic
- Manually split oversized items in the queue

---

## 6. Monitor the Rejection Rate

The Verify loop rejection rate is the single most important health metric.

| Rate | Interpretation | Action |
|---|---|---|
| < 20% | Healthy — Build loop is producing good output | None needed |
| 20–50% | Elevated — review recent rejections for patterns | Tune Build prompt or work item quality |
| > 50% | High — something is wrong | Pause, investigate, fix before continuing |

Check the rejection rate:

```bash
claude loop status --json | jq '.metrics.verify.rejection_rate'
```

Review rejection reasons to find patterns:

```bash
cat .claude/state/rejected.json | jq '.[].rejection_reasons' | sort | uniq -c | sort -rn
```

---

## 7. Handle Context Window Saturation

Claude Code agents have a finite context window. In long sessions, agents may encounter large codebases or complex work items that approach this limit.

### Prevention

- Keep work items scoped to specific files and functions
- Avoid including large generated files in the repository (or add them to a context exclusion list)
- Configure the Build agent to read only the files directly relevant to the work item

### Detection

Watch for these signs in the build log:
- Unusually slow cycles
- Implementation that ignores parts of the work item
- Generic or incorrect code that doesn't match the codebase style

### Recovery

If context saturation is suspected:
1. Pause the Build loop
2. Check the work item — is it too large?
3. Split the work item into smaller pieces
4. Resume

---

## 8. Maintain an Audit Log

Every autonomous action should be auditable. Ensure the audit log is:

- **Written to disk**, not just memory
- **Append-only** — do not rotate or truncate it during active sessions
- **Backed up** periodically

Key events to include in the audit log:
- Work item created (with source)
- Work item started by Build
- Work item completed / rejected / escalated
- PR opened, approved, merged, or closed
- Loop started, stopped, paused, resumed
- Human override actions

---

## 9. Daily Review Ritual

Even in a fully autonomous system, daily human review is valuable.

### Suggested daily review (10–15 minutes)

1. **Check loop status** — all three loops running, no unexpected restarts
2. **Review merged PRs** — scan titles and descriptions, spot-check 1–2 diffs
3. **Check escalated items** — resolve any `needs_human_review` items
4. **Review rejection reasons** — look for recurring patterns
5. **Check queue depth** — is the queue growing faster than it's being processed?
6. **Check API cost** — on track for budget?

---

## 10. Know When to Stop

Autonomous systems should be stopped and manually reviewed when:

- A production incident occurs — pause loops until the incident is resolved
- The rejection rate exceeds 50% for more than 2 hours
- The same work item has been rejected more than 3 times
- A change was merged that should not have been
- Any unexpected modification to protected paths is detected
- API costs are growing faster than expected

When stopping for investigation:

```bash
claude loop stop all --force
# Review what happened
cat .claude/logs/build-loop.log | grep -E "ERROR|WARN" | tail -50
cat .claude/state/audit.log | tail -100
```

Do not restart until you understand what happened and have addressed it.

---

## 11. Version Control Your Configuration

Your `.claude/config.yaml` and prompt files define the entire behavior of the autonomous system. Treat them as code:

- Commit them to the repository
- Review changes with the same care as code changes
- Use meaningful commit messages when updating them
- Tag stable configurations so you can roll back

```bash
git add .claude/config.yaml prompts/
git commit -m "config: tighten monitor priority rules for CI failures"
```

---

## 12. Test Configuration Changes in Observation Mode

Before deploying prompt or configuration changes to a running system:

1. Stop the system
2. Apply the change
3. Run Monitor loop only for one or two cycles (`claude loop run-once monitor`)
4. Review the generated work items
5. If satisfactory, restart the full system

Never change configuration while loops are running.

---

## Summary Checklist

Before starting a long autonomous session:

- [ ] Protected paths configured and reviewed
- [ ] API cost limits set
- [ ] Alerts configured (loop errors, escalations, rejection rate)
- [ ] State and log directories created and have write access
- [ ] Ramp-up plan defined (not jumping straight to full autonomous)
- [ ] Audit log configured
- [ ] Daily review schedule established
- [ ] Team informed that the system is running
- [ ] Emergency stop procedure understood (`claude loop stop all --force`)

---

## Related Documents

- [Autonomous Development Workflow](../operations/autonomous-development-workflow.md)
- [Claude Start Guide](../operations/claude-start-guide.md)
- [Triple Loop Architecture](../architecture/triple-loop-architecture.md)
