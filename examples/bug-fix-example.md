# Example: Autonomous Bug Fix Cycle

This walkthrough demonstrates a complete autonomous bug detection and fix cycle — from CI failure detection through root cause analysis, fix implementation, verification, and merge.

---

## Scenario

**Repository:** A Python web service
**Problem:** A CI pipeline failure caused by a failing unit test

---

## Step 1: Monitor Loop Detects the CI Failure

**Trigger:** A CI pipeline run fails on the `main` branch after a recent merge.

The Monitor loop reads the CI results during its scheduled cycle.

### CI failure details (from GitHub Actions)

```
Run: #214
Branch: main
Commit: a3f91b2
Status: FAILED

Failed jobs:
  - test (Python 3.11)

Failure log:
  FAILED tests/test_auth.py::test_token_expiry_returns_401
  AssertionError: 200 != 401
```

### Monitor agent input (task prompt excerpt)

```
## Recent CI Results

[
  {
    "run_id": 214,
    "branch": "main",
    "commit": "a3f91b2",
    "status": "failure",
    "failed_jobs": ["test"],
    "failure_summary": "FAILED tests/test_auth.py::test_token_expiry_returns_401\nAssertionError: 200 != 401",
    "run_url": "https://github.com/org/service/actions/runs/214"
  }
]
```

### Monitor agent output

```json
[
  {
    "id": "WI-61",
    "type": "bug_fix",
    "priority": "high",
    "title": "Auth endpoint returns 200 instead of 401 for expired tokens",
    "description": "CI run #214 on main (commit a3f91b2) fails with: test_token_expiry_returns_401 - AssertionError: 200 != 401. The auth endpoint is returning a 200 OK response when it should return 401 Unauthorized for expired JWT tokens. This is a regression on the main branch.",
    "source": "ci_pipeline",
    "source_id": "CI-214",
    "source_url": "https://github.com/org/service/actions/runs/214",
    "acceptance_criteria": [
      "The failing test test_token_expiry_returns_401 passes",
      "Requests with an expired JWT token receive a 401 Unauthorized response",
      "Requests with a valid JWT token continue to receive a 200 response",
      "No existing auth tests are broken by the fix"
    ],
    "labels": ["bug", "auth", "security"],
    "created_by": "monitor-agent"
  }
]
```

**State store updated:** WI-61 added to `work_queue` with `priority: high`

---

## Step 2: Build Loop Investigates and Fixes the Bug

The Build loop dequeues WI-61 (high priority) and begins investigation.

### Exploration phase

The Build agent reads:
- `tests/test_auth.py` — the failing test
- `src/auth/middleware.py` — the auth middleware
- `src/auth/jwt_utils.py` — JWT utility functions
- `git log --oneline -5 a3f91b2` — recent commits to identify the regression

**Recent commits:**

```
a3f91b2 feat(auth): add support for token refresh
9d2a18b test: add integration tests for user endpoints
7f3c44a fix: update dependency versions
```

The most recent commit `a3f91b2` ("add support for token refresh") is the most likely cause.

**`src/auth/middleware.py`** (after commit a3f91b2):

```python
def require_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization', '').replace('Bearer ', '')
        if not token:
            return jsonify({'error': 'No token provided'}), 401

        try:
            payload = jwt_utils.decode_token(token)
        except jwt.ExpiredSignatureError:
            # Token expired — try to refresh
            refresh_result = jwt_utils.try_refresh(token)
            if refresh_result:
                payload = refresh_result
            # Bug: missing else clause -- falls through to handler below with payload=None
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Invalid token'}), 401

        return f(payload, *args, **kwargs)
    return decorated
```

**Root cause identified:** The `except jwt.ExpiredSignatureError` block attempts a token refresh. If the refresh fails (`refresh_result` is `None`), the code falls through without returning a 401, calling `f(None, ...)` instead. The fix is to add an `else` / explicit 401 return when refresh fails.

### Implementation

Branch created: `auto/fix-auth-expired-token-WI-61`

**`src/auth/middleware.py`** (fixed):

```python
def require_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get('Authorization', '').replace('Bearer ', '')
        if not token:
            return jsonify({'error': 'No token provided'}), 401

        try:
            payload = jwt_utils.decode_token(token)
        except jwt.ExpiredSignatureError:
            refresh_result = jwt_utils.try_refresh(token)
            if refresh_result:
                payload = refresh_result
            else:
                return jsonify({'error': 'Token expired'}), 401
        except jwt.InvalidTokenError:
            return jsonify({'error': 'Invalid token'}), 401

        return f(payload, *args, **kwargs)
    return decorated
```

The Build agent also reviews the test to ensure it correctly tests the scenario:

**`tests/test_auth.py`** (existing test — no changes needed):

```python
def test_token_expiry_returns_401(client):
    expired_token = create_expired_token(user_id=1)
    response = client.get('/api/me', headers={'Authorization': f'Bearer {expired_token}'})
    assert response.status_code == 401
    assert response.json['error'] == 'Token expired'
```

The existing test already covers the exact scenario. No test changes are needed — just the fix.

### Local validation

```
$ flake8 src/
  ✓ No lint errors

$ pytest tests/test_auth.py -v
  ✓ test_no_token_returns_401 PASSED
  ✓ test_invalid_token_returns_401 PASSED
  ✓ test_valid_token_returns_200 PASSED
  ✓ test_token_expiry_returns_401 PASSED    ← previously failing
  ✓ test_refresh_succeeds_with_valid_refresh_token PASSED
  ✓ test_refresh_fails_with_expired_refresh_token PASSED

  6 passed
```

### Pull request opened

PR #94: `auto/fix-auth-expired-token-WI-61` → `main`

```markdown
## Summary

Fixes a regression introduced in a3f91b2 where expired tokens that fail to refresh
were not returning a 401. Added the missing `else` clause in the ExpiredSignatureError
handler to explicitly return 401 when token refresh fails.

## Work Item

- **ID:** WI-61
- **Type:** bug_fix
- **Source:** CI run #214 (commit a3f91b2)

## Root Cause

The `except jwt.ExpiredSignatureError` block in `require_auth` added in a3f91b2
attempted token refresh but had no `else` branch — when `try_refresh` returned None,
execution fell through and called the endpoint handler with `payload=None`.

## Changes Made

- `src/auth/middleware.py`: Added `else: return 401` to the expired token handler

## Acceptance Criteria

- [x] test_token_expiry_returns_401 now passes
- [x] Expired tokens without a valid refresh receive 401
- [x] Valid tokens continue to receive 200
- [x] All existing auth tests pass

## Local Checks

- [x] Flake8 lint: passed
- [x] pytest tests/test_auth.py: 6/6 passed
```

**State store updated:** WI-61 moved to `pending_verification`, CH-41 recorded

---

## Step 3: Verify Loop Reviews the Fix

The Verify loop picks up CH-41 and reviews PR #94.

### CI results

CI on the PR branch:
- Lint (flake8): ✓ passed
- Unit tests: 28/28 passed (all tests in test suite)
- Coverage: 87% (unchanged)

### Verify agent decision

```json
{
  "change_id": "CH-41",
  "work_item_id": "WI-61",
  "decision": "approved",
  "summary": "Root cause correctly identified and fixed with minimal scope. All acceptance criteria met.",
  "acceptance_criteria_review": [
    {
      "criterion": "The failing test test_token_expiry_returns_401 passes",
      "status": "passed",
      "evidence": "CI results show all 6 auth tests passing including test_token_expiry_returns_401."
    },
    {
      "criterion": "Requests with an expired JWT token receive a 401 Unauthorized response",
      "status": "passed",
      "evidence": "middleware.py:14-16 now returns 401 when try_refresh returns None."
    },
    {
      "criterion": "Requests with a valid JWT token continue to receive a 200 response",
      "status": "passed",
      "evidence": "test_valid_token_returns_200 passes. The fix only adds an else branch and does not affect the success path."
    },
    {
      "criterion": "No existing auth tests are broken by the fix",
      "status": "passed",
      "evidence": "All 28 tests pass in CI."
    }
  ],
  "code_quality_notes": [
    "Change is minimal and surgical — exactly one else clause added. Good scope.",
    "The regression was introduced in a3f91b2 by omitting the else branch. The fix correctly restores the intended behavior."
  ],
  "checks_reviewed": {
    "lint": "passed",
    "unit_tests": "passed",
    "ci_pipeline": "passed",
    "security_scan": "not_applicable"
  },
  "decided_by": "verify-agent",
  "decided_at": "2025-01-15T14:20:00Z"
}
```

### Merge

PR #94 approved and squash-merged to `main`. Branch deleted.

**State store updated:** WI-61 moved to `completed`.

---

## Summary

| Step | Duration | Actor |
|---|---|---|
| Regression introduced by merge | — | Human (accidental) |
| CI run #214 fails | ~4 min | CI pipeline |
| Monitor loop detects failure, creates WI-61 | ~1 min | Monitor agent |
| Build loop investigates root cause, fixes | ~6 min | Build agent |
| CI runs on fix branch | ~4 min | CI pipeline |
| Verify loop reviews and approves | ~2 min | Verify agent |
| **Total time from regression to fix merged** | **~17 min** | |

The bug was detected from a CI failure, root-caused to the correct commit and line, fixed minimally, and merged — without any human involvement in the debugging or fixing process.

---

## What If the First Fix Attempt Failed?

If the Build loop's fix had been wrong — for example, fixing the wrong file — the Verify loop would have rejected it:

```json
{
  "decision": "rejected",
  "rejection_reasons": [
    "test_token_expiry_returns_401 still fails in CI — the fix did not address the root cause.",
    "The changed code (jwt_utils.py) is not the location of the regression. The middleware.py try/except block is the correct location."
  ]
}
```

The work item would return to the queue with the rejection reason appended. On the next Build cycle, the Build agent would have the additional context to make a better attempt.

---

## Related Documents

- [Feature Development Example](feature-development-example.md)
- [Triple Loop Architecture](../architecture/triple-loop-architecture.md)
- [Build Loop](../loops/build-loop.md)
- [Verify Loop](../loops/verify-loop.md)
