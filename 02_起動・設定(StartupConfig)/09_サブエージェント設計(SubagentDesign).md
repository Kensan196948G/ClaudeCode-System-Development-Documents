# 09 サブエージェント設計（Subagent Design）

---

## 概要

Claude Code の**サブエージェント**機能は、メインのClaudeセッションが複数の専門エージェントに並列タスクを委譲する仕組みです。
バックエンドAPI実装とフロントエンド実装を同時進行させたり、テストと実装を並列実行させたりと、開発速度を大幅に向上させます。

---

## サブエージェントの仕組み

```
メインエージェント（オーケストレーター）
        │
        ├── サブエージェント A（バックエンド実装）
        │       ├── Read: src/api/*.ts
        │       ├── Write: src/api/user.ts
        │       └── bash: npm test
        │
        ├── サブエージェント B（フロントエンド実装）
        │       ├── Read: src/components/*.tsx
        │       ├── Write: src/components/UserCard.tsx
        │       └── bash: npm run build
        │
        └── サブエージェント C（テスト作成）
                ├── Read: src/api/user.ts（A の成果物を参照）
                └── Write: tests/api/user.test.ts
```

---

## サブエージェントの起動方法

### 方法 1: CLAUDE.md でのサブエージェント定義

```markdown
## サブエージェント設定

以下のパターンで並列実行を活用してください：

### 大規模機能実装時
- バックエンドAgent: API エンドポイント実装（src/api/）
- フロントエンドAgent: UI コンポーネント実装（src/components/）
- テストAgent: テストコード作成（tests/）
- ドキュメントAgent: README/JSDoc 更新

### 各 Agent は独立したファイル空間で作業し、完了後にメインに報告すること。
```

### 方法 2: プロンプトでの直接指示

```
"以下のタスクを並列サブエージェントに分けて実行してください：
1. バックエンド: User API の CRUD エンドポイントを実装
2. フロントエンド: User 管理画面コンポーネントを実装
3. テスト: 上記両方のユニットテストを作成"
```

### 方法 3: settings.json での定義

```json
{
  "subagents": {
    "enabled": true,
    "maxParallel": 4,
    "defaultModel": "claude-sonnet-4-5",
    "agents": {
      "backend": {
        "workingDirs": ["src/api", "src/services", "src/models"],
        "allowedTools": ["Read", "Write", "Edit", "bash"],
        "systemPromptAppend": "バックエンドAPIの実装に特化してください。フロントエンドファイルは変更しないこと。"
      },
      "frontend": {
        "workingDirs": ["src/components", "src/pages", "src/hooks"],
        "allowedTools": ["Read", "Write", "Edit"],
        "systemPromptAppend": "Reactコンポーネントの実装に特化してください。"
      },
      "testing": {
        "workingDirs": ["tests", "spec"],
        "allowedTools": ["Read", "Write", "bash"],
        "systemPromptAppend": "テストコードの作成と実行に特化してください。"
      }
    }
  }
}
```

---

## サブエージェントのパターン集

### パターン 1: 機能実装の並列化

```
タスク: "ユーザー認証機能を実装してください"

メインエージェント → 設計・タスク分解
  ├── Backend Agent
  │   ├── JWT 認証ミドルウェア実装
  │   ├── ユーザーモデル実装
  │   └── 認証 API エンドポイント実装
  │
  └── Frontend Agent
      ├── ログインフォームコンポーネント
      ├── 認証状態管理（Context/Zustand）
      └── プロテクトルート実装
  
  ↓ 両エージェント完了後
Integration Agent
  ├── E2E テスト実行
  └── 結合テスト確認
```

### パターン 2: レビューと実装の並列化

```
タスク: "PR をレビューして問題があれば修正してください"

  ├── Review Agent
  │   ├── セキュリティ問題の検出
  │   ├── パフォーマンス問題の検出
  │   └── レビューレポート生成
  │
  └── Test Agent
      ├── テストカバレッジ分析
      └── 不足テストの特定

  ↓ レポート完成後
Fix Agent
  └── 検出問題の修正実装
```

### パターン 3: マルチリポジトリ対応

```
タスク: "マイクロサービスのAPIバージョンを v1 から v2 に移行"

  ├── Service-A Agent (./services/auth/)
  │   └── Auth API v2 移行
  ├── Service-B Agent (./services/user/)
  │   └── User API v2 移行
  ├── Service-C Agent (./services/payment/)
  │   └── Payment API v2 移行
  └── Gateway Agent (./services/gateway/)
      └── API Gateway ルーティング更新
```

---

## Triple Loop × サブエージェント

### 7体エージェント構成との統合

```
Triple Loop のエージェントチームをサブエージェントに割り当て:

Monitor Loop（メインエージェント）
  ├── 要件分析Agent   → 改善タスクリスト生成
  └── アーキテクトAgent → 設計決定

Build Loop（並列サブエージェント）
  ├── 実装Agent      → コード実装
  ├── テストAgent    → テスト作成
  ├── セキュリティAgent → 脆弱性チェック
  └── DevOpsAgent   → CI/CD 更新

Verify Loop（メインエージェント）
  ├── CI/CD 実行確認
  └── 品質ゲート検証
```

### CLAUDE.md への追記例

```markdown
## Build Loop サブエージェント設定

Build Loop では以下の並列サブエージェントを使用してください:

### Agent チーム構成（Build ステップ）

**実装Agent（`implementation`）**
- 担当: src/ 配下のすべての実装ファイル
- ツール: Read, Write, Edit, bash

**テストAgent（`testing`）**
- 担当: tests/ または spec/ 配下のテストファイル
- ツール: Read, Write, bash(npm test のみ)

**ドキュメントAgent（`docs`）**
- 担当: docs/, README.md, JSDoc コメント
- ツール: Read, Write

### 実行ルール
- 実装Agentが完了するまでテストAgentは待機
- 各Agentは自分の担当ファイル以外は変更不可
- メインへの報告: 完了した作業の要約と変更ファイルリストを報告
```

---

## Hooks によるサブエージェント監視

```json
{
  "hooks": {
    "SubagentStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo \"[$(date '+%H:%M:%S')] サブエージェント起動: $CLAUDE_SUBAGENT_ID\" >> /tmp/agents.log"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo \"[$(date '+%H:%M:%S')] サブエージェント完了: $CLAUDE_SUBAGENT_ID\" >> /tmp/agents.log"
          }
        ]
      }
    ]
  }
}
```

---

## 制限と注意事項

| 項目 | 内容 |
|------|------|
| **最大並列数** | デフォルト 4（settings.json の `maxParallel` で変更） |
| **ファイル競合** | 同じファイルに複数エージェントが書き込む場合は逐次実行に変更 |
| **API レート制限** | 並列実行はAPI使用量が増加するため注意 |
| **コンテキスト共有** | サブエージェント間でコンテキストは共有されない（ファイル経由で共有） |
| **チェックポイント** | 各サブエージェントが独立してチェックポイントを作成 |
| **コスト** | 並列実行はトークン消費が並列数に比例して増加 |

---

## デバッグ

```bash
# サブエージェントのログ確認
cat ~/.claude/logs/subagents.log

# アクティブなサブエージェント一覧
claude subagents list

# サブエージェントの強制終了
claude subagents kill <subagent-id>
```

---

## 関連ドキュメント

- [Hooks設定ガイド](./06_Hooks設定ガイド(HooksConfig).md)
- [settings.json 設定ガイド](./07_settings_json設定ガイド(SettingsJson).md)
- [Claude Agent SDK](../01_システム概要(SystemOverview)/07_Claude_Agent_SDK(AgentSDK).md)
- [エージェント構成](../01_システム概要(SystemOverview)/03_エージェント構成(AgentConfiguration).md)
