# ClaudeCode 系统开发文档

ClaudeCode 自主软件开发系统的文档集。  
基于 **Triple Loop 架构** 和 7 体 Agent 团队，实现持续自主软件开发。

---

## 快速导航

| 目标 | 文档 |
|------|------|
| 5分钟快速开始 | [快速入门](../docs-en/QuickStart.md) |
| 了解架构 | [架构概览](../docs-en/ArchitectureOverview.md) |
| 配置 Claude Code | [配置指南](../docs-en/SettingsGuide.md)（英文） |

---

## 系统概览

Triple Loop 架构让 Claude 自主循环执行 Monitor → Build → Verify 三个阶段：

```
┌─────────────────────────────────────────────────────┐
│         ClaudeCode 自主开发系统                       │
│                                                     │
│  ┌────────────┐  ┌────────────┐  ┌──────────────┐  │
│  │Monitor循环  │→ │ Build 循环 │→ │ Verify 循环  │  │
│  │（监控·规划） │  │（实现·构建）│  │（验证·确认）  │  │
│  └────────────┘  └────────────┘  └──────────────┘  │
│        ↑                                  │         │
│        └──────────────────────────────────┘         │
│                  自主循环继续                         │
└─────────────────────────────────────────────────────┘
```

### Claude Code 2.0 主要特性

| 特性 | 说明 |
|------|------|
| **Checkpoints** | 每次工具调用前自动保存；用 `/rewind` 或 `Esc×2` 还原 |
| **VS Code 扩展** | 原生侧边栏、内联差异显示 |
| **Hooks** | 10+ 生命周期事件（PreToolUse、PostToolUse…） |
| **子 Agent** | 并行任务分发给专用子 Agent |
| **MCP** | 通过 Model Context Protocol 连接 Slack、Jira、GitHub、数据库 |
| **Agent SDK** | 用代码构建自定义 Agent |

---

## 文件夹结构

```
ClaudeCode-System-Development-Documents/
├── 01_システム概要/          ← 架构、Agent、快速入门
├── 02_起動・設定/            ← CLAUDE.md、settings.json、Hooks、MCP
├── 03_開発シナリオ/          ← 新功能、Bug修复等提示词
├── 08_チュートリアル/        ← 实操教程
├── 09_事例集/               ← 实际项目应用案例
├── templates/               ← 即用 .claude/ 模板
├── docs-en/                 ← 英文文档
└── docs-zh/                 ← 中文文档（本文件夹）
```

---

## 快速安装

```bash
# 安装 Claude Code CLI
npm install -g @anthropic-ai/claude-code

# 认证
claude auth login

# 复制模板
cp -r templates/.claude /path/to/your-project/.claude

# 启动
claude
```

---

### 📁 [08_教程(Tutorials)](<../08_チュートリアル(Tutorials)/>)
分步操作指南，边做边学。

| 文件 | 内容 |
|------|------|
| [01_首次运行TripleLoop](<../08_チュートリアル(Tutorials)/01_初めてのTripleLoop実行(FirstTripleLoop).md>) | Triple Loop 15H 的首次启动步骤 |
| [05_子代理并行执行](<../08_チュートリアル(Tutorials)/05_サブエージェント並列実行(SubagentParallel).md>) | 通过并行子代理实现高速开发 |

### 📁 [09_案例集(UseCases)](<../09_事例集(UseCases)/>)
实际项目的应用案例与成功模式。

| 文件 | 内容 |
|------|------|
| [03_事故响应案例](<../09_事例集(UseCases)/03_インシデント対応活用事例(IncidentResponseCase).md>) | 45分钟解决深夜事故 |
| [04_Python_FastAPI案例](<../09_事例集(UseCases)/04_Python_FastAPI適用事例(PythonFastAPICase).md>) | 测试覆盖率 58%→88% |

---

## 许可证

[MIT License](../LICENSE)
