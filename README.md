# ClaudeCode System Development Documents

A knowledge base and documentation hub for autonomous software development using **Claude Code**.

This repository organizes architecture designs, operational guides, prompt examples, and best practices for engineers building and running AI-driven autonomous development systems.

---

## What Is This?

Claude Code can be configured to operate in a fully autonomous loop — continuously monitoring, building, and verifying software without human intervention between cycles. This repository documents how that system works, how to set it up, and how to operate it reliably in production.

---

## Table of Contents

### 🏗 Architecture

| Document | Description |
|---|---|
| [Triple Loop Architecture](architecture/triple-loop-architecture.md) | The three-loop system that drives autonomous development |
| [Autonomous Development Architecture](architecture/autonomous-development-architecture.md) | High-level system design for AI-driven development |
| [Agent Teams System](architecture/agent-teams-system.md) | How multiple AI agents are orchestrated as teams |

### 🔄 Loops

| Document | Description |
|---|---|
| [Monitor Loop](loops/monitor-loop.md) | Continuously observes the system and detects issues |
| [Build Loop](loops/build-loop.md) | Implements features and fixes based on detected work |
| [Verify Loop](loops/verify-loop.md) | Validates the correctness and quality of completed work |

### ⚙️ Operations

| Document | Description |
|---|---|
| [Claude Start Guide](operations/claude-start-guide.md) | How to start Claude Code for autonomous sessions |
| [Loop Command Usage](operations/loop-command-usage.md) | Commands for controlling the three-loop system |
| [Autonomous Development Workflow](operations/autonomous-development-workflow.md) | End-to-end workflow for a full autonomous development cycle |

### 💬 Prompts

| Document | Description |
|---|---|
| [Monitor Loop Prompts](prompts/monitor-loop-prompts.md) | System and task prompts used by the Monitor loop |
| [Verify Loop Prompts](prompts/verify-loop-prompts.md) | System and task prompts used by the Verify loop |

### ✅ Best Practices

| Document | Description |
|---|---|
| [Long Autonomous Sessions](best-practices/long-autonomous-sessions.md) | Guidance for running stable, productive autonomous sessions |

### 📖 Examples

| Document | Description |
|---|---|
| [Feature Development Example](examples/feature-development-example.md) | Walkthrough of an autonomous feature development cycle |
| [Bug Fix Example](examples/bug-fix-example.md) | Walkthrough of an autonomous bug detection and fix cycle |

---

## Quick Start

```bash
# 1. Start Claude Code in autonomous mode
claude --headless --system-prompt prompts/monitor-loop-prompts.md

# 2. Run the monitor loop
./scripts/run-monitor-loop.sh

# 3. Run the build loop
./scripts/run-build-loop.sh

# 4. Run the verify loop
./scripts/run-verify-loop.sh
```

See [Claude Start Guide](operations/claude-start-guide.md) for detailed setup instructions.

---

## Repository Structure

```
ClaudeCode-System-Development-Documents/
├── README.md
├── architecture/
│   ├── triple-loop-architecture.md
│   ├── autonomous-development-architecture.md
│   └── agent-teams-system.md
├── loops/
│   ├── monitor-loop.md
│   ├── build-loop.md
│   └── verify-loop.md
├── operations/
│   ├── claude-start-guide.md
│   ├── loop-command-usage.md
│   └── autonomous-development-workflow.md
├── prompts/
│   ├── monitor-loop-prompts.md
│   └── verify-loop-prompts.md
├── best-practices/
│   └── long-autonomous-sessions.md
└── examples/
    ├── feature-development-example.md
    └── bug-fix-example.md
```

---

## Contributing

Documentation improvements and new examples are welcome. Please keep all documents in clear, engineer-friendly markdown and follow the existing folder structure.

---

## License

See [LICENSE](LICENSE).
