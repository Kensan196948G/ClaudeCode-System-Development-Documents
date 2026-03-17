# Quick Start Guide

Get up and running with the ClaudeCode Autonomous Development System in 5 minutes.

---

## Prerequisites

| Requirement | Version | Check |
|-------------|---------|-------|
| Node.js | 18.x or later | `node --version` |
| Git | 2.x or later | `git --version` |
| GitHub CLI | 2.x or later | `gh --version` |
| Anthropic API Key | — | [console.anthropic.com](https://console.anthropic.com) |

---

## Step 1: Install Claude Code CLI

```bash
npm install -g @anthropic-ai/claude-code

# Verify
claude --version
```

## Step 2: Authenticate

```bash
claude auth login
# Enter your Anthropic API key when prompted
```

## Step 3: (Optional) Install VS Code Extension

```bash
# Via VS Code Marketplace
code --install-extension anthropic.claude-code

# Or via CLI
claude setup vscode
```

## Step 4: Set Up Your Project

```bash
# Clone or create your project
git clone https://github.com/your-org/your-project.git
cd your-project

# Create the .claude/ directory from template
mkdir -p .claude/commands .claude/hooks .claude/mcp-configs

# Download settings template
curl -o .claude/settings.json \
  https://raw.githubusercontent.com/Kensan196948G/ClaudeCode-System-Development-Documents/main/templates/.claude/settings.json

# Download CLAUDE.md template
curl -o .claude/CLAUDE.md \
  https://raw.githubusercontent.com/Kensan196948G/ClaudeCode-System-Development-Documents/main/templates/.claude/CLAUDE.md
```

## Step 5: Configure CLAUDE.md

Edit `.claude/CLAUDE.md` — replace the placeholders:

```markdown
# Replace:
[PROJECT_NAME]  → your actual project name
[TypeScript / Python / Go]  → your language
[Express / FastAPI / Gin]   → your framework
```

## Step 6: Launch Claude Code

```bash
claude
```

## Step 7: Start the Triple Loop

In the Claude Code prompt, type:

```
/loop 900m execute Triple Loop 15H (2-Cycle) autonomous development
```

For a shorter single cycle (8 hours):

```
/loop 450m execute Triple Loop 8H (1-Cycle) autonomous development
```

---

## Key Commands

| Command | Description |
|---------|-------------|
| `/rewind` | Open checkpoint menu to restore previous state |
| `/model claude-opus-4-6` | Switch to a more powerful model |
| `Esc + Esc` | Quick access to checkpoint menu |
| `/review` | Run custom code review (if configured) |

---

## Troubleshooting

### Claude Code doesn't respond
```bash
ps aux | grep claude
cat ~/.claude/logs/latest.log
```

### API rate limit error
- Increase sleep interval in `triple-loop-15h.sh`
- Upgrade your Anthropic API plan

### Restore a previous state
```
/rewind
→ Select "Restore code only" or "Restore code + conversation"
```

---

## Next Steps

- [Architecture Overview](./ArchitectureOverview.md) — Understand the Triple Loop
- [Settings Guide](./SettingsGuide.md) — Fine-tune Claude's behavior
- [Hooks Guide](./HooksGuide.md) — Automate your workflow
- [MCP Guide](./MCPGuide.md) — Connect Slack, GitHub, databases
