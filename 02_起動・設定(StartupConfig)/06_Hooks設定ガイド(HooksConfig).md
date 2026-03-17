# 06 Hooks 設定ガイド（Hooks Config）

---

## 概要

Claude Code の **Hooks** は、エージェントのライフサイクルイベントにシェルコマンドやスクリプトを紐づける仕組みです。
コード変更の前後に自動テストを実行したり、特定ツールの使用を通知したりと、開発ワークフローを柔軟に自動化できます。

---

## Hooks の設定場所

Hooks は `.claude/settings.json` または `~/.claude/settings.json` で定義します：

```json
{
  "hooks": {
    "PreToolUse": [...],
    "PostToolUse": [...],
    "SubagentStart": [...],
    "SubagentStop": [...],
    "Notification": [...]
  }
}
```

---

## イベント一覧

| イベント | タイミング | 主な用途 |
|---------|-----------|---------|
| **PreToolUse** | ツール実行前 | バリデーション・確認ダイアログ・ブロック |
| **PostToolUse** | ツール実行後 | テスト実行・ログ記録・通知 |
| **SubagentStart** | サブエージェント起動時 | ログ・リソース確保 |
| **SubagentStop** | サブエージェント終了時 | 結果収集・クリーンアップ |
| **Notification** | Claude からの通知 | デスクトップ通知・Slack通知 |
| **Stop** | セッション終了時 | 最終レポート生成・後処理 |
| **SessionStart** | セッション開始時 | 環境チェック・初期化 |
| **UserPromptSubmit** | ユーザー入力後 | インプット前処理・ログ |
| **MessageStart** | Claude の返答開始時 | UI更新 |
| **MessageStop** | Claude の返答完了時 | ログ・コスト計算 |

---

## 基本設定例

### 設定ファイルの構造

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": {
          "tool_name": "Write"
        },
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint -- --fix $CLAUDE_FILE_PATH"
          }
        ]
      }
    ]
  }
}
```

### マッチャーの種類

```json
// ツール名でマッチ
"matcher": { "tool_name": "bash" }

// ツールの入力内容でマッチ（正規表現）
"matcher": { "tool_input": ".*\\.prod\\..*" }

// 複数条件（AND）
"matcher": {
  "tool_name": "Write",
  "tool_input": ".*\\.ts$"
}
```

---

## 実用的なHooks設定集

### 1. ファイル変更後に自動テスト実行

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
            "timeout": 60000
          }
        ]
      }
    ]
  }
}
```

### 2. 本番設定ファイルの変更を禁止（PreToolUse ブロック）

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": {
          "tool_name": "Write",
          "tool_input": ".*\\.(prod|production)\\.(env|json|yaml)$"
        },
        "hooks": [
          {
            "type": "block",
            "reason": "本番設定ファイルの直接変更は禁止されています。レビュープロセスを経てください。"
          }
        ]
      }
    ]
  }
}
```

### 3. コミット前のコード品質チェック

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": { "tool_name": "bash", "tool_input": "git commit.*" },
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint && npm run type-check",
            "on_failure": "block"
          }
        ]
      }
    ]
  }
}
```

### 4. Slack 通知（セッション完了時）

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "curl -s -X POST $SLACK_WEBHOOK_URL -H 'Content-type: application/json' -d '{\"text\": \"Claude Code セッションが完了しました\"}'"
          }
        ]
      }
    ]
  }
}
```

### 5. デスクトップ通知（macOS）

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"$CLAUDE_NOTIFICATION_MESSAGE\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

### 6. デスクトップ通知（Linux）

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "notify-send 'Claude Code' \"$CLAUDE_NOTIFICATION_MESSAGE\""
          }
        ]
      }
    ]
  }
}
```

### 7. コスト追跡ログ

```json
{
  "hooks": {
    "MessageStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo \"$(date -Iseconds) tokens=$CLAUDE_INPUT_TOKENS+$CLAUDE_OUTPUT_TOKENS\" >> ~/.claude/cost-log.txt"
          }
        ]
      }
    ]
  }
}
```

---

## 環境変数一覧

Hooks のコマンド内で使用できる環境変数：

| 変数名 | 内容 |
|--------|------|
| `$CLAUDE_FILE_PATH` | 操作対象ファイルのパス |
| `$CLAUDE_TOOL_NAME` | 実行されたツール名 |
| `$CLAUDE_TOOL_INPUT` | ツールへの入力値 |
| `$CLAUDE_TOOL_OUTPUT` | ツールの出力値 |
| `$CLAUDE_INPUT_TOKENS` | 入力トークン数 |
| `$CLAUDE_OUTPUT_TOKENS` | 出力トークン数 |
| `$CLAUDE_SESSION_ID` | セッション ID |
| `$CLAUDE_NOTIFICATION_MESSAGE` | 通知メッセージ |
| `$CLAUDE_SUBAGENT_ID` | サブエージェント ID |
| `$CLAUDE_WORKING_DIRECTORY` | 作業ディレクトリ |

---

## Triple Loop 用 Hooks 設定例

`.claude/settings.json` に以下を追加することで Triple Loop の動作をカスタマイズできます：

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": { "tool_name": "bash", "tool_input": ".*rm -rf.*" },
        "hooks": [{ "type": "block", "reason": "危険なコマンドは禁止されています" }]
      }
    ],
    "PostToolUse": [
      {
        "matcher": { "tool_name": "Write" },
        "hooks": [
          {
            "type": "command",
            "command": "echo \"[$(date '+%H:%M:%S')] ファイル更新: $CLAUDE_FILE_PATH\" >> /tmp/claude-activity.log"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo '=== ループ完了 ===' >> /tmp/claude-activity.log && git log --oneline -10 >> /tmp/claude-activity.log"
          }
        ]
      }
    ]
  }
}
```

---

## on_failure オプション

```json
{
  "type": "command",
  "command": "npm test",
  "on_failure": "block"     // コマンド失敗時にツール実行をブロック
  // or
  "on_failure": "warn"      // 警告のみ（デフォルト）
  // or
  "on_failure": "ignore"    // 失敗を無視して続行
}
```

---

## 関連ドキュメント

- [settings.json 設定ガイド](./07_settings_json設定ガイド(SettingsJson).md)
- [サブエージェント設計](./09_サブエージェント設計(SubagentDesign).md)
- [CLAUDE.md 設定ガイド](./05_CLAUDE_MD設定ガイド(CLAUDEMDConfig).md)
- [チェックポイント機能](../01_システム概要(SystemOverview)/05_チェックポイント機能(Checkpoints).md)
