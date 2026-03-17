# 08 MCP 設定ガイド（MCP Config）

---

## 概要

**MCP（Model Context Protocol）** は、Claude Code を外部ツール・サービスと接続するための標準プロトコルです。
Slack、Jira、GitHub、データベースなどへのリアルタイムアクセスを可能にし、コード開発の文脈を超えた統合ワークフローを実現します。

---

## MCP の仕組み

```
Claude Code
    │
    ▼
MCP クライアント（Claude Code 内蔵）
    │
    ├── GitHub MCP Server    ── Issues/PR/Repo にアクセス
    ├── Slack MCP Server     ── チャンネル読み書き
    ├── Jira MCP Server      ── チケット管理
    ├── PostgreSQL MCP Server── データベースクエリ
    └── Custom MCP Server    ── 自作ツール連携
```

MCP サーバーは**ローカルプロセス**または**リモートHTTPS**として動作します。

---

## インストールと初期設定

### 公式 MCP サーバーのインストール

```bash
# GitHub MCP
npm install -g @anthropic-ai/mcp-server-github

# Slack MCP
npm install -g @anthropic-ai/mcp-server-slack

# ファイルシステム MCP（ローカルファイルアクセス拡張）
npm install -g @anthropic-ai/mcp-server-filesystem

# PostgreSQL MCP
npm install -g @anthropic-ai/mcp-server-postgres
```

### Claude Code への登録

```bash
# インタラクティブで追加
claude mcp add

# コマンドラインで追加
claude mcp add github --env GITHUB_TOKEN=ghp_xxxxxxxxxxxx
claude mcp add slack --env SLACK_BOT_TOKEN=xoxb-xxxxxxxxxxxx
```

---

## 設定ファイル

### `.claude/mcp-configs/github.json`

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

### `.claude/mcp-configs/slack.json`

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

### `.claude/mcp-configs/postgres.json`

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

---

## 利用できる主要 MCP サーバー

| サービス | パッケージ | 主な機能 |
|---------|-----------|---------|
| **GitHub** | `@anthropic-ai/mcp-server-github` | Issues・PR・Repository操作 |
| **Slack** | `@anthropic-ai/mcp-server-slack` | チャンネル読み書き・検索 |
| **Jira** | `@anthropic-ai/mcp-server-jira` | チケット作成・更新・検索 |
| **Google Drive** | `@anthropic-ai/mcp-server-gdrive` | ドキュメント読み書き |
| **PostgreSQL** | `@anthropic-ai/mcp-server-postgres` | SQL クエリ実行 |
| **SQLite** | `@anthropic-ai/mcp-server-sqlite` | ローカルDB操作 |
| **Filesystem** | `@anthropic-ai/mcp-server-filesystem` | ファイルシステム拡張アクセス |
| **Browser** | `@anthropic-ai/mcp-server-puppeteer` | Webブラウザ操作・スクリーンショット |

---

## 使用例

### GitHub Issues から開発タスクを自動取得

```
# Claude Code で実行
"GitHub の未解決 Issues を取得して、優先順位の高いバグを修正してください"

→ MCP が GitHub API を呼び出し
→ Issue 一覧を取得
→ 優先度の高いバグを自動修正
→ PR を自動作成
```

### Slack でのインシデント対応

```
"Slack の #incident チャンネルの直近のメッセージを確認して、
 現在のインシデントの状況を要約してください"

→ Slack MCP が #incident チャンネルを読み取り
→ インシデント状況を要約
→ 関連するコードの問題箇所を特定して修正提案
```

### データベースのスキーマ分析

```
"PostgreSQL データベースのスキーマを確認して、
 パフォーマンス改善のためのインデックス追加提案をしてください"

→ PostgreSQL MCP がスキーマ情報を取得
→ クエリパターンを分析
→ インデックス追加の SQL を生成
```

---

## settings.json での MCP 有効化

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

---

## カスタム MCP サーバーの作成

自社の社内 API や独自ツールを MCP サーバーとして公開できます：

```typescript
// custom-mcp-server.ts
import { MCPServer, Tool } from '@anthropic-ai/mcp-sdk';

const server = new MCPServer({
  name: 'my-company-api',
  version: '1.0.0'
});

server.addTool({
  name: 'get_deploy_status',
  description: '現在のデプロイ状況を取得します',
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
  description: '指定環境へのデプロイを実行します',
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

## Triple Loop での MCP 活用

```
Triple Loop 15H + MCP 統合例:

Monitor Loop
  → GitHub MCP で未解決 Issues を取得
  → Jira MCP でスプリントバックログを確認
  → 改善タスクリストを生成

Build Loop
  → コード実装
  → GitHub MCP で PR を自動作成
  → Jira MCP でチケットのステータスを更新

Verify Loop
  → テスト実行
  → Slack MCP で結果をチームに通知
  → GitHub MCP で PR に自動レビューコメント
```

---

## セキュリティ考慮事項

| 項目 | 推奨事項 |
|------|---------|
| **認証情報** | 環境変数を使用（設定ファイルにハードコードしない） |
| **最小権限** | 必要な capabilities のみ有効化 |
| **本番DB接続** | 読み取り専用アカウントを使用 |
| **ログ記録** | MCP のアクセスログを記録・監査 |
| **タイムアウト** | 長時間のMCP呼び出しにはタイムアウトを設定 |

---

## 接続状態の確認

```bash
# 接続中の MCP サーバー一覧
claude mcp list

# 特定サーバーの状態確認
claude mcp status github

# MCP のログ確認
claude mcp logs
```

---

## 関連ドキュメント

- [settings.json 設定ガイド](./07_settings_json設定ガイド(SettingsJson).md)
- [Hooks設定ガイド](./06_Hooks設定ガイド(HooksConfig).md)
- [サブエージェント設計](./09_サブエージェント設計(SubagentDesign).md)
- [Claude Agent SDK](../01_システム概要(SystemOverview)/07_Claude_Agent_SDK(AgentSDK).md)
