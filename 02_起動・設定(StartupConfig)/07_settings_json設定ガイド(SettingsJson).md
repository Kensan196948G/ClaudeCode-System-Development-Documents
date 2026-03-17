# 07 settings.json 設定ガイド（Settings Json）

---

## 概要

`settings.json` は Claude Code の動作設定を細かく制御するための設定ファイルです。
ツールの許可/禁止、自動承認ルール、モデル選択、Hooks など、Claude の振る舞いをプロジェクト・ユーザーレベルで管理できます。

---

## 設定ファイルの場所と優先順位

```
優先度 高 ←────────────────────────────→ 低

プロジェクトレベル        ユーザーレベル
.claude/settings.json  ~/.claude/settings.json
```

プロジェクト設定がユーザー設定を上書きします。どちらも存在する場合はマージされます。

---

## .claude/ ディレクトリの全体構造

```
.claude/
├── settings.json          ← メイン設定ファイル
├── CLAUDE.md              ← プロジェクト固有のシステムプロンプト補足
├── skills/                ← カスタムスキル定義（将来機能）
├── agents/                ← カスタムエージェント定義
├── commands/              ← カスタムコマンド（/slash コマンド）
│   ├── review.md          ← /review コマンドの定義
│   └── deploy.md          ← /deploy コマンドの定義
├── hooks/                 ← フックスクリプト
│   ├── pre-commit.sh      ← コミット前チェック
│   └── post-write.sh      ← ファイル書き込み後
└── mcp-configs/           ← MCP サーバー設定
    ├── github.json        ← GitHub MCP
    └── slack.json         ← Slack MCP
```

---

## settings.json の完全リファレンス

```json
{
  // デフォルトモデル設定
  "model": "claude-sonnet-4-5",

  // ツール許可設定
  "permissions": {
    "allow": [
      "Read",
      "Write",
      "Edit",
      "bash",
      "Glob",
      "Grep",
      "WebFetch",
      "TodoRead",
      "TodoWrite"
    ],
    "deny": [
      "bash(rm -rf*)",
      "bash(sudo rm*)",
      "WebFetch(*.malicious-site.com*)"
    ]
  },

  // 自動承認設定
  "autoApprove": {
    "enabled": true,
    "rules": [
      // 読み取り操作は常に自動承認
      { "tool": "Read", "auto": true },
      { "tool": "Grep", "auto": true },
      { "tool": "Glob", "auto": true },

      // テスト実行は自動承認
      { "tool": "bash", "pattern": "npm test.*", "auto": true },
      { "tool": "bash", "pattern": "pytest.*", "auto": true },

      // 本番環境への操作は手動承認
      { "tool": "bash", "pattern": ".*prod.*deploy.*", "auto": false }
    ]
  },

  // Hooks 設定（詳細は 06_Hooks設定ガイド を参照）
  "hooks": {
    "PreToolUse": [...],
    "PostToolUse": [...],
    "Notification": [...]
  },

  // コンテキスト設定
  "context": {
    "autoLoadFiles": ["README.md", "CLAUDE.md", "package.json"],
    "maxContextFiles": 50,
    "includeGitHistory": true
  },

  // 出力設定
  "output": {
    "verbosity": "normal",         // "quiet" | "normal" | "verbose"
    "colorEnabled": true,
    "progressIndicator": true
  },

  // セッション設定
  "session": {
    "checkpointsEnabled": true,
    "historyRetentionDays": 30,
    "maxTurnsPerSession": 200
  },

  // MCP 設定（詳細は 08_MCP設定ガイド を参照）
  "mcp": {
    "enabled": true,
    "configPath": ".claude/mcp-configs/"
  }
}
```

---

## よく使う設定パターン

### パターン 1: 安全重視（本番環境・共有リポジトリ）

```json
{
  "model": "claude-sonnet-4-5",
  "permissions": {
    "allow": ["Read", "Grep", "Glob"],
    "deny": ["Write", "Edit", "bash"]
  },
  "autoApprove": {
    "enabled": false
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": { "tool_name": "bash" },
        "hooks": [{ "type": "block", "reason": "本番環境ではbash実行は禁止" }]
      }
    ]
  }
}
```

### パターン 2: 全自律開発（Triple Loop）

```json
{
  "model": "claude-sonnet-4-5",
  "permissions": {
    "allow": ["Read", "Write", "Edit", "bash", "Glob", "Grep", "WebFetch"],
    "deny": [
      "bash(sudo rm -rf /*)",
      "bash(DROP TABLE*)",
      "bash(*--force*push*)"
    ]
  },
  "autoApprove": {
    "enabled": true,
    "rules": [
      { "tool": "Read", "auto": true },
      { "tool": "Write", "pattern": "src/.*", "auto": true },
      { "tool": "bash", "pattern": "npm (test|lint|build).*", "auto": true },
      { "tool": "bash", "pattern": "git (add|commit|status|log|diff).*", "auto": true }
    ]
  },
  "session": {
    "checkpointsEnabled": true,
    "maxTurnsPerSession": 500
  }
}
```

### パターン 3: コードレビュー専用

```json
{
  "model": "claude-opus-4-6",
  "permissions": {
    "allow": ["Read", "Grep", "Glob", "bash"],
    "deny": ["Write", "Edit"]
  },
  "autoApprove": {
    "enabled": true
  },
  "context": {
    "autoLoadFiles": ["README.md", "CLAUDE.md"],
    "includeGitHistory": true
  }
}
```

---

## カスタムコマンド（/slash コマンド）

`.claude/commands/` フォルダにMarkdownファイルを置くことで、カスタム `/slash` コマンドを作成できます：

```markdown
<!-- .claude/commands/review.md -->
# /review コマンド

このコマンドはコードレビューを実行します。

## 実行手順

1. 変更ファイルを一覧表示
2. 各ファイルのコード品質を評価
3. セキュリティ問題を検出
4. 改善提案を日本語で出力

## 出力形式

```
## コードレビュー結果

### ✅ 良い点
- ...

### ⚠️ 改善提案
- ...

### 🔴 問題点
- ...
```
```

使用方法：

```
/review
```

---

## モデル選択ガイド

| モデル | 用途 | コスト |
|--------|------|--------|
| `claude-sonnet-4-5` | 日常的な開発作業（**デフォルト**） | 中 |
| `claude-opus-4-6` | 複雑なアーキテクチャ設計・深い分析 | 高 |
| `claude-haiku-4-5` | 簡単なタスク・高速処理 | 低 |

`/model` コマンドでセッション中に動的に変更：

```
/model claude-opus-4-6
```

---

## 設定のバリデーション

```bash
# settings.json の構文チェック
claude config validate

# 現在の有効な設定を表示
claude config show

# 特定の設定値を確認
claude config get permissions.allow
```

---

## 関連ドキュメント

- [Hooks設定ガイド](./06_Hooks設定ガイド(HooksConfig).md)
- [CLAUDE.md 設定ガイド](./05_CLAUDE_MD設定ガイド(CLAUDEMDConfig).md)
- [MCP設定ガイド](./08_MCP設定ガイド(MCPConfig).md)
- [サブエージェント設計](./09_サブエージェント設計(SubagentDesign).md)
