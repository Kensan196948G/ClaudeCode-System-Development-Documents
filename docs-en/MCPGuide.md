# MCP Guide: Model Context Protocol Configuration

---

## What is MCP (Model Context Protocol)?

**MCP (Model Context Protocol)** is a standard protocol that connects Claude Code to external tools and services. It enables real-time access to systems such as Slack, Jira, GitHub, and databases, allowing Claude Code to operate in integrated workflows that go beyond local code development.

With MCP, Claude Code can:
- Read and create GitHub Issues and Pull Requests
- Post messages to Slack channels and read incident threads
- Query a live database to analyze schemas and suggest optimizations
- Interact with any custom internal API exposed as an MCP server

### How MCP Works

```
Claude Code
    │
    ▼
MCP Client (built into Claude Code)
    │
    ├── GitHub MCP Server     ──  Access Issues / PRs / Repositories
    ├── Slack MCP Server      ──  Read and write channels
    ├── Jira MCP Server       ──  Manage tickets
    ├── PostgreSQL MCP Server ──  Execute database queries
    └── Custom MCP Server     ──  Connect your own internal tools
```

MCP servers run either as **local processes** (stdio) or as **remote HTTPS** endpoints.

---

## Available MCP Servers

| Service | Package | Key Capabilities |
|---------|---------|-----------------|
| **GitHub** | `@anthropic-ai/mcp-server-github` | Issues, Pull Requests, repository operations |
| **Slack** | `@anthropic-ai/mcp-server-slack` | Read/write channels, search messages |
| **Jira** | `@anthropic-ai/mcp-server-jira` | Create, update, and search tickets |
| **Google Drive** | `@anthropic-ai/mcp-server-gdrive` | Read and write documents |
| **PostgreSQL** | `@anthropic-ai/mcp-server-postgres` | Execute SQL queries |
| **SQLite** | `@anthropic-ai/mcp-server-sqlite` | Local database operations |
| **Filesystem** | `@anthropic-ai/mcp-server-filesystem` | Extended local filesystem access |
| **Browser** | `@anthropic-ai/mcp-server-puppeteer` | Web browser automation, screenshots |

---

## Installation

### Install Official MCP Servers

```bash
# GitHub MCP
npm install -g @anthropic-ai/mcp-server-github

# Slack MCP
npm install -g @anthropic-ai/mcp-server-slack

# Filesystem MCP (extended local file access)
npm install -g @anthropic-ai/mcp-server-filesystem

# PostgreSQL MCP
npm install -g @anthropic-ai/mcp-server-postgres
```

### Register with Claude Code

```bash
# Interactive registration
claude mcp add

# Register via command line with credentials
claude mcp add github --env GITHUB_TOKEN=ghp_xxxxxxxxxxxx
claude mcp add slack  --env SLACK_BOT_TOKEN=xoxb-xxxxxxxxxxxx
```

---

## Configuration in settings.json

Enable MCP and reference individual server config files from `.claude/settings.json`:

```json
{
  "mcp": {
    "enabled": true,
    "servers": {
      "github": {
        "enabled": true,
        "configPath": ".claude/mcp-configs/github.json"
      },
      "slack": {
        "enabled": true,
        "configPath": ".claude/mcp-configs/slack.json"
      }
    },
    "autoConnect": true,
    "timeout": 30000
  }
}
```

- `"autoConnect": true` — automatically connects to all enabled MCP servers when Claude Code starts.
- `"timeout"` — maximum time (in milliseconds) to wait for an MCP server response.

---

## GitHub MCP Example

### Configuration file: `.claude/mcp-configs/github.json`

```json
{
  "name": "github",
  "type": "stdio",
  "command": "mcp-server-github",
  "env": {
    "GITHUB_TOKEN": "${GITHUB_TOKEN}"
  },
  "capabilities": [
    "issues",
    "pull_requests",
    "repositories",
    "search"
  ]
}
```

Always use environment variable references (`${GITHUB_TOKEN}`) rather than hardcoding tokens in the config file.

### Usage example

Once the GitHub MCP is connected, you can ask Claude Code:

```
"Fetch all open Issues labeled 'bug' and fix the highest-priority one."

→ MCP calls the GitHub API
→ Retrieves the issue list
→ Implements a fix in the codebase
→ Automatically creates a Pull Request
```

### Triple Loop integration

```
Monitor Loop
  → GitHub MCP fetches unresolved Issues
  → Jira MCP checks the sprint backlog
  → Generates a prioritized task list

Build Loop
  → Implements code changes
  → GitHub MCP automatically creates a PR
  → Jira MCP updates ticket status

Verify Loop
  → Runs tests
  → Slack MCP notifies the team of results
  → GitHub MCP posts automated review comments on the PR
```

---

## Slack MCP Example

### Configuration file: `.claude/mcp-configs/slack.json`

```json
{
  "name": "slack",
  "type": "stdio",
  "command": "mcp-server-slack",
  "env": {
    "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}",
    "SLACK_TEAM_ID": "${SLACK_TEAM_ID}"
  },
  "capabilities": [
    "channels_read",
    "messages_read",
    "messages_write"
  ]
}
```

Grant only the capabilities your workflow actually needs (`channels_read`, `messages_read`, `messages_write`) to follow the principle of least privilege.

### Usage example

```
"Check the latest messages in the #incident channel and summarize the current incident status."

→ Slack MCP reads the #incident channel
→ Claude summarizes the incident situation
→ Identifies the likely code location causing the problem
→ Proposes a fix
```

---

## Additional MCP Configuration Examples

### PostgreSQL: `.claude/mcp-configs/postgres.json`

```json
{
  "name": "postgres",
  "type": "stdio",
  "command": "mcp-server-postgres",
  "args": ["postgresql://user:pass@localhost:5432/mydb"],
  "capabilities": [
    "query",
    "schema_read"
  ]
}
```

Use a **read-only** database account for production connections to prevent accidental data modification.

### PostgreSQL Use Case: Schema Analysis and Index Optimization

Example workflow using Claude Code with PostgreSQL MCP:

1. Analyze schema → `Retrieve tables and relationships from the production DB`
2. Detect slow queries → `Show queries taking over 1 second in the last 24 hours`
3. Suggest indexes → Claude analyzes and proposes `CREATE INDEX` statements
4. Validate impact → `Run EXPLAIN ANALYZE on the proposed index`
5. Apply change → Claude generates and executes the migration

This workflow reduces manual DBA work for routine index optimization tasks.

### Custom Internal API MCP Server

You can expose any internal API as an MCP server using the MCP SDK:

```typescript
// custom-mcp-server.ts
import { MCPServer, Tool } from '@anthropic-ai/mcp-sdk';

const server = new MCPServer({
  name: 'my-company-api',
  version: '1.0.0'
});

server.addTool({
  name: 'get_deploy_status',
  description: 'Retrieve the current deployment status',
  parameters: {
    environment: { type: 'string', enum: ['dev', 'staging', 'prod'] }
  },
  handler: async ({ environment }) => {
    const status = await myCompanyAPI.getDeployStatus(environment);
    return { status: status.state, version: status.version, timestamp: status.updatedAt };
  }
});

server.addTool({
  name: 'trigger_deploy',
  description: 'Trigger a deployment to the specified environment',
  parameters: {
    environment: { type: 'string', enum: ['dev', 'staging'] },
    branch: { type: 'string' }
  },
  handler: async ({ environment, branch }) => {
    const result = await myCompanyAPI.deploy(environment, branch);
    return { deployId: result.id, status: 'triggered' };
  }
});

server.start();
```

Register the custom server:

```json
// .claude/mcp-configs/custom.json
{
  "name": "my-company-api",
  "type": "stdio",
  "command": "node",
  "args": ["./custom-mcp-server.js"]
}
```

---

## Security Considerations

| Area | Recommendation |
|------|---------------|
| **Credentials** | Always use environment variables — never hardcode tokens in config files |
| **Least privilege** | Enable only the `capabilities` your workflow actually requires |
| **Production databases** | Use a read-only account when connecting to production databases |
| **Audit logging** | Record MCP access logs and review them regularly |
| **Timeouts** | Set a `"timeout"` for long-running MCP calls to prevent indefinite blocking |

---

## Checking Connection Status

```bash
# List all connected MCP servers
claude mcp list

# Check the status of a specific server
claude mcp status github

# View MCP logs
claude mcp logs
```

---

## Related Documents

- [SettingsGuide.md](./SettingsGuide.md)
- [HooksGuide.md](./HooksGuide.md)
- [ArchitectureOverview.md](./ArchitectureOverview.md)
- [QuickStart.md](./QuickStart.md)
