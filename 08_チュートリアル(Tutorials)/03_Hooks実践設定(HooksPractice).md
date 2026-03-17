# 03 Hooks 実践設定（Hooks Practice）

---

## このチュートリアルの目的

**所要時間**: 約30分  
**難易度**: ⭐⭐⭐☆☆ 中級  
**前提**: `.claude/settings.json` が作成済み

ファイル変更後の自動テスト・危険コマンドのブロック・Slack通知の3つを実際に設定します。

---

## ハンズオン 1: ファイル変更後に自動テストを実行

`.claude/settings.json` を編集します：

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": { "tool_name": "Write" },
        "hooks": [
          {
            "type": "command",
            "command": "npm test -- --passWithNoTests --bail 2>&1 | tail -20",
            "timeout": 60000,
            "on_failure": "warn"
          }
        ]
      }
    ]
  }
}
```

**確認方法**: Claude にファイルを変更させると、変更後にテストが自動実行されます。

---

## ハンズオン 2: 危険なコマンドをブロック

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": {
          "tool_name": "bash",
          "tool_input": ".*(rm -rf|DROP TABLE|--force push).*"
        },
        "hooks": [
          {
            "type": "block",
            "reason": "危険な操作は禁止されています。手動で実行してください。"
          }
        ]
      }
    ]
  }
}
```

**確認方法**: Claude に `rm -rf node_modules` を実行させると、ブロックされます。

---

## ハンズオン 3: セッション完了時にログを保存

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo '=== セッション完了: '$(date)' ===' >> ~/claude-sessions.log && git log --oneline -5 >> ~/claude-sessions.log 2>&1"
          }
        ]
      }
    ]
  }
}
```

**確認方法**: `cat ~/claude-sessions.log` でセッション履歴を確認できます。

---

## 設定の組み合わせ（完成版）

```json
{
  "model": "claude-sonnet-4-5",
  "permissions": {
    "allow": ["Read", "Write", "Edit", "bash", "Glob", "Grep"],
    "deny": ["bash(sudo rm -rf*)"]
  },
  "autoApprove": {
    "enabled": true,
    "rules": [
      { "tool": "Read", "auto": true },
      { "tool": "bash", "pattern": "npm (test|lint|build).*", "auto": true }
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": { "tool_name": "bash", "tool_input": ".*(rm -rf|--force).*" },
        "hooks": [{ "type": "block", "reason": "危険なコマンドは禁止" }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": { "tool_name": "Write" },
        "hooks": [
          {
            "type": "command",
            "command": "npm test -- --passWithNoTests --bail 2>&1 | tail -10",
            "timeout": 60000,
            "on_failure": "warn"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo 'セッション完了: '$(date) >> ~/claude-sessions.log"
          }
        ]
      }
    ]
  }
}
```

---

## 次のチュートリアル

- [04_MCP外部連携入門](./04_MCP連携入門(MCPIntro).md)
- [05_サブエージェント並列実行](./05_サブエージェント並列実行(SubagentParallel).md)
