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

## 📁 [08_Tutorials](<../08_チュートリアル(Tutorials)/>)

Step-by-step hands-on guides.

| File | Content |
|------|---------|
| [01_FirstTripleLoop](<../08_チュートリアル(Tutorials)/01_初めてのTripleLoop実行(FirstTripleLoop).md>) | How to run Triple Loop 15H for the first time |
| [02_VSCodeTutorial](<../08_チュートリアル(Tutorials)/02_VSCode拡張機能活用(VSCodeTutorial).md>) | Using inline diff and sidebar in VS Code |
| [03_HooksPractice](<../08_チュートリアル(Tutorials)/03_Hooks実践設定(HooksPractice).md>) | Configuring auto-test, blocking, and notification hooks |
| [04_MCPIntro](<../08_チュートリアル(Tutorials)/04_MCP連携入門(MCPIntro).md>) | Getting started with GitHub MCP |
| [05_SubagentParallel](<../08_チュートリアル(Tutorials)/05_サブエージェント並列実行(SubagentParallel).md>) | High-speed development with parallel sub-agents |

---

## 📁 [09_UseCases](<../09_事例集(UseCases)/>)

Real-world adoption cases, success patterns, and lessons learned.

| File | Content |
|------|---------|
| [01_NodeJSRestAPI](<../09_事例集(UseCases)/01_NodeJS_REST_API適用事例(NodeJSRestAPICase).md>) | Applying Triple Loop to Node.js/TypeScript API |
| [02_ReactFrontend](<../09_事例集(UseCases)/02_React_フロントエンド適用事例(ReactFrontendCase).md>) | React 18 migration and large-scale type annotation |
| [03_IncidentResponse](<../09_事例集(UseCases)/03_インシデント対応活用事例(IncidentResponseCase).md>) | Resolved a midnight incident in 45 minutes |
| [04_PythonFastAPI](<../09_事例集(UseCases)/04_Python_FastAPI適用事例(PythonFastAPICase).md>) | Quality improvement with Python/FastAPI (coverage 58%→88%) |
| [05_SecurityResponse](<../09_事例集(UseCases)/05_セキュリティ脆弱性対応事例(SecurityResponseCase).md>) | Fixed a Critical CVE in 2.5 hours with recurrence prevention |

---

## License

[MIT License](../LICENSE)
