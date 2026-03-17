# Example: Autonomous Feature Development Cycle

This walkthrough demonstrates a complete autonomous feature development cycle — from issue detection through code implementation, verification, and merge — using the Triple Loop system.

---

## Scenario

**Repository:** A Node.js REST API
**Feature requested:** A user has filed a GitHub issue requesting CSV export for the `/api/reports` endpoint

---

## Step 1: Monitor Loop Detects the Issue

**Trigger:** GitHub Issue #88 opened: *"Add CSV export option to reports API"*

The Monitor loop runs its cycle, reads the open GitHub issues, and evaluates Issue #88.

### Monitor agent input (task prompt excerpt)

```
## GitHub Issues

[
  {
    "number": 88,
    "title": "Add CSV export option to reports API",
    "body": "Currently /api/reports only returns JSON. It would be useful to be able to request CSV format for use in spreadsheet tools. Could be triggered by a query parameter like ?format=csv",
    "labels": ["enhancement"],
    "author": "jsmith",
    "created_at": "2025-01-15T09:00:00Z"
  }
]
```

### Monitor agent output

```json
[
  {
    "id": "WI-52",
    "type": "feature",
    "priority": "medium",
    "title": "Add CSV export to /api/reports endpoint",
    "description": "GitHub Issue #88 requests CSV export from /api/reports. Currently the endpoint returns JSON only. The requester suggests using a ?format=csv query parameter to trigger CSV output. The CSV should contain the same data as the JSON response, formatted as a standard comma-separated file with headers.",
    "source": "github_issue",
    "source_id": "GH-88",
    "source_url": "https://github.com/org/api/issues/88",
    "acceptance_criteria": [
      "GET /api/reports?format=csv returns a CSV file with the correct Content-Type header (text/csv)",
      "The CSV contains column headers matching the JSON field names",
      "The CSV contains the same data rows as the JSON response",
      "GET /api/reports (no format param) continues to return JSON unchanged",
      "Unit tests cover: CSV format request, JSON default, invalid format parameter"
    ],
    "labels": ["enhancement", "api"],
    "created_by": "monitor-agent"
  }
]
```

**State store updated:** WI-52 added to `work_queue`

---

## Step 2: Build Loop Implements the Feature

The Build loop polls the queue, picks up WI-52 (highest priority in queue), and begins implementation.

### Exploration phase

The Build agent reads:
- `src/api/reports.js` — the existing reports endpoint
- `src/middleware/format.js` — existing format handling
- `tests/api/reports.test.js` — existing tests
- `package.json` — available dependencies

It finds that:
- The endpoint already has a `?format` query parameter stub (unused)
- There is no CSV library installed, but the Node.js built-in `stream` module can handle it
- The test file uses Jest

### Implementation

The Build agent creates feature branch `auto/feature-csv-export-WI-52` and makes these changes:

**`src/api/reports.js`** (modified)

```javascript
const { formatReports } = require('../utils/format-reports');

router.get('/reports', async (req, res) => {
  const reports = await Report.findAll();
  const format = req.query.format || 'json';

  if (format === 'csv') {
    const csv = formatReports.toCSV(reports);
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename="reports.csv"');
    return res.send(csv);
  }

  if (format !== 'json') {
    return res.status(400).json({ error: `Unsupported format: ${format}. Use 'json' or 'csv'.` });
  }

  res.json(reports);
});
```

**`src/utils/format-reports.js`** (new file)

```javascript
function toCSV(reports) {
  if (!reports || reports.length === 0) return '';
  const headers = Object.keys(reports[0]);
  const rows = reports.map(r => headers.map(h => JSON.stringify(r[h] ?? '')).join(','));
  return [headers.join(','), ...rows].join('\n');
}

module.exports = { toCSV };
```

**`tests/api/reports.test.js`** (modified — new tests added)

```javascript
describe('GET /api/reports', () => {
  // ... existing tests ...

  describe('CSV format', () => {
    it('returns CSV with correct Content-Type', async () => {
      const res = await request(app).get('/api/reports?format=csv');
      expect(res.status).toBe(200);
      expect(res.headers['content-type']).toMatch(/text\/csv/);
    });

    it('CSV contains headers matching JSON fields', async () => {
      const res = await request(app).get('/api/reports?format=csv');
      const firstLine = res.text.split('\n')[0];
      expect(firstLine).toBe('id,name,value,created_at');
    });

    it('CSV contains correct data rows', async () => {
      const res = await request(app).get('/api/reports?format=csv');
      const lines = res.text.split('\n');
      expect(lines.length).toBeGreaterThan(1);
    });

    it('returns 400 for unsupported format', async () => {
      const res = await request(app).get('/api/reports?format=xml');
      expect(res.status).toBe(400);
    });
  });

  it('returns JSON when no format param provided', async () => {
    const res = await request(app).get('/api/reports');
    expect(res.status).toBe(200);
    expect(res.headers['content-type']).toMatch(/application\/json/);
  });
});
```

### Local validation

```
$ npm run lint
  ✓ No lint errors

$ npm test
  ✓ GET /api/reports returns 200
  ✓ GET /api/reports?format=csv returns CSV with correct Content-Type
  ✓ CSV contains headers matching JSON fields
  ✓ CSV contains correct data rows
  ✓ returns 400 for unsupported format
  ✓ returns JSON when no format param provided

  6 tests passed
```

### Pull request opened

PR #91: `auto/feature-csv-export-WI-52` → `main`

```markdown
## Summary

Adds CSV export to the /api/reports endpoint via a ?format=csv query parameter.
JSON remains the default. Invalid format values return a 400 with a clear error.

## Work Item

- **ID:** WI-52
- **Type:** feature
- **Source:** GH-88

## Changes Made

- `src/api/reports.js`: Added format handling logic
- `src/utils/format-reports.js`: New CSV formatter utility
- `tests/api/reports.test.js`: 4 new tests

## Acceptance Criteria

- [x] CSV format request returns text/csv Content-Type
- [x] CSV contains column headers matching JSON field names
- [x] CSV contains the same data rows as JSON
- [x] JSON default is unchanged
- [x] Tests cover all cases

## Local Checks

- [x] Lint: passed
- [x] Unit tests: passed (6/6)
```

**State store updated:** WI-52 moved to `pending_verification`, CH-33 recorded

---

## Step 3: Verify Loop Reviews the Change

The Verify loop picks up CH-33 and reviews PR #91.

### CI results

CI has run on the branch:
- Lint: ✓ passed
- Unit tests: 6/6 passed
- Integration tests: 4/4 passed
- Coverage: 84% (was 83%)

### Verify agent decision

```json
{
  "change_id": "CH-33",
  "work_item_id": "WI-52",
  "decision": "approved",
  "summary": "All acceptance criteria met, tests pass, implementation is clean.",
  "acceptance_criteria_review": [
    {
      "criterion": "GET /api/reports?format=csv returns a CSV file with the correct Content-Type header (text/csv)",
      "status": "passed",
      "evidence": "src/api/reports.js:8 sets Content-Type to text/csv. Test confirms in reports.test.js:45."
    },
    {
      "criterion": "The CSV contains column headers matching the JSON field names",
      "status": "passed",
      "evidence": "format-reports.js:3 uses Object.keys() to derive headers from data. Test confirms at reports.test.js:51."
    },
    {
      "criterion": "The CSV contains the same data rows as the JSON response",
      "status": "passed",
      "evidence": "format-reports.js:4 maps all fields from each report object."
    },
    {
      "criterion": "GET /api/reports (no format param) continues to return JSON unchanged",
      "status": "passed",
      "evidence": "Default is json at reports.js:5. Test confirms at reports.test.js:60."
    },
    {
      "criterion": "Unit tests cover: CSV format request, JSON default, invalid format parameter",
      "status": "passed",
      "evidence": "4 new tests added covering all three scenarios."
    }
  ],
  "code_quality_notes": [
    "format-reports.js is a clean, focused utility — good separation of concerns.",
    "JSON.stringify used for CSV cell values handles special characters (quotes, commas) safely."
  ],
  "checks_reviewed": {
    "lint": "passed",
    "unit_tests": "passed",
    "ci_pipeline": "passed",
    "security_scan": "not_applicable"
  },
  "decided_by": "verify-agent",
  "decided_at": "2025-01-15T11:45:00Z"
}
```

### Merge

PR #91 approved and squash-merged to `main`. Branch deleted.

**State store updated:** WI-52 moved to `completed`. CH-33 recorded as approved + merged.

---

## Summary

| Step | Duration | Actor |
|---|---|---|
| Issue #88 opened | — | Human |
| Monitor loop detects issue, creates WI-52 | ~2 min | Monitor agent |
| Build loop implements feature | ~8 min | Build agent |
| CI runs on PR | ~4 min | CI pipeline |
| Verify loop reviews and approves | ~3 min | Verify agent |
| **Total cycle time** | **~17 min** | |

The feature was detected, implemented, tested, reviewed, and merged — with zero human intervention.

---

## Related Documents

- [Bug Fix Example](bug-fix-example.md)
- [Triple Loop Architecture](../architecture/triple-loop-architecture.md)
- [Autonomous Development Workflow](../operations/autonomous-development-workflow.md)
