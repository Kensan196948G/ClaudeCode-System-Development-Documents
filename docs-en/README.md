# ClaudeCode System Development Documents

English documentation for the ClaudeCode Autonomous Software Development System.  
This system implements a **Triple Loop Architecture** with a 7-agent team for continuous, autonomous software development.

---

## Quick Navigation

| Goal | Document |
|------|----------|
| Get started in 5 minutes | [Quick Start](./QuickStart.md) |
| Understand the architecture | [Architecture Overview](./ArchitectureOverview.md) |
| Configure Claude Code | [Settings Guide](./SettingsGuide.md) |
| Set up hooks | [Hooks Guide](./HooksGuide.md) |
| Connect external tools | [MCP Guide](./MCPGuide.md) |

---

## System Overview

The ClaudeCode Autonomous Development System uses the **Triple Loop Architecture** where Claude Code continuously executes Monitor → Build → Verify cycles to deliver high-quality software.

```
┌─────────────────────────────────────────────────────┐
│         ClaudeCode Autonomous Dev System            │
│                                                     │
│  ┌────────────┐  ┌────────────┐  ┌──────────────┐  │
│  │Monitor Loop│→ │ Build Loop │→ │ Verify Loop  │  │
│  │(Plan)      │  │(Implement) │  │(Validate)    │  │
│  └────────────┘  └────────────┘  └──────────────┘  │
│        ↑                                  │         │
│        └──────────────────────────────────┘         │
│                  Autonomous Loop                    │
└─────────────────────────────────────────────────────┘
```

### Key Features (Claude Code 2.0)

| Feature | Description |
|---------|-------------|
| **Checkpoints** | Auto-save before every tool call; restore with `/rewind` or `Esc×2` |
| **VS Code Extension** | Native sidebar, inline diff, editor integration |
| **Hooks** | 10+ lifecycle events (PreToolUse, PostToolUse, Notification, Stop…) |
| **Subagents** | Parallel task delegation to specialized sub-agents |
| **MCP** | Connect Slack, Jira, GitHub, databases via Model Context Protocol |
| **Agent SDK** | Build custom agents programmatically |
| **200K+ Context** | Process large codebases in a single session |

---

## Folder Structure

```
ClaudeCode-System-Development-Documents/
├── 01_SystemOverview/          ← Architecture, agents, quick start
├── 02_StartupConfig/           ← CLAUDE.md, settings.json, Hooks, MCP
├── 03_DevelopmentScenarios/    ← Prompts for new features, bug fixes…
├── 04_InfraDevOps/             ← CI/CD, security, Docker, deploy
├── 05_TechnicalImplementation/ ← API, frontend, database, auth
├── 06_MaintenanceMigration/    ← Migration, incident response, tech debt
├── 07_DocumentationKnowledge/  ← Doc generation, coding standards
├── templates/                  ← Ready-to-use .claude/ templates
└── docs-en/                    ← English documentation (this folder)
```

---

## Getting Started

### Prerequisites

```bash
# Install Claude Code CLI
npm install -g @anthropic-ai/claude-code

# Verify installation
claude --version

# Authenticate
claude auth login
```

### 5-Minute Setup

```bash
# 1. Clone or create your project
git clone https://github.com/your-org/your-project.git
cd your-project

# 2. Copy the .claude/ template
cp -r /path/to/ClaudeCode-System-Development-Documents/templates/.claude ./.claude

# 3. Edit CLAUDE.md with your project details
nano .claude/CLAUDE.md

# 4. Start Claude Code
claude

# 5. Launch the Triple Loop
# Type in the Claude Code prompt:
# /loop 900m start Triple Loop 15H autonomous development
```

---

## The 7-Agent Team

| Agent | Trigger | Responsibility |
|-------|---------|----------------|
| Requirements | `as requirements-agent` | Analyze requirements from Issues/specs |
| Architect | `as architect-agent` | System design, module split, API design |
| Implementation | `as implementation-agent` | Write code, refactoring |
| Testing | `as testing-agent` | Test strategy, test code creation |
| Security | `as security-agent` | Vulnerability scanning, compliance |
| DevOps | `as devops-agent` | CI/CD, IaC, pipeline automation |
| Documentation | `as docs-agent` | Technical writing, changelogs |

---

## License

[MIT License](../LICENSE)
