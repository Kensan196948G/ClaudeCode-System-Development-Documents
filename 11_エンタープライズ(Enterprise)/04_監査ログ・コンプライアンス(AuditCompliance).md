# 04 監査ログ・コンプライアンスガイド

> **概要**: Claude Code の全操作を記録する監査ログの設定、コンプライアンス対応、ログ分析の方法を解説します。

---

## 監査ログの概要

監査ログは Claude Code が実行した全操作を記録するセキュリティ・コンプライアンス機能です。

```
記録される情報:
├── セッション開始・終了（タイムスタンプ、ユーザー、プロジェクト）
├── ツール呼び出し（種類、引数、結果）
├── ファイル操作（読み取り、書き込み、削除）
├── Bash 実行（コマンド、出力、終了コード）
└── モデル呼び出し（プロンプト、レスポンス、トークン数）
```

---

## 監査ログの設定

### settings.json での設定

```json
{
  "auditLog": {
    "enabled": true,
    "level": "detailed",
    "format": "json",
    "events": {
      "sessionLifecycle": true,
      "toolCalls": true,
      "fileOperations": true,
      "bashCommands": true,
      "modelCalls": {
        "enabled": true,
        "includePrompts": false,
        "includeResponses": false
      }
    },
    "output": {
      "file": {
        "enabled": true,
        "path": "~/.claude/logs/audit/",
        "rotation": "daily",
        "maxFiles": 90
      },
      "syslog": {
        "enabled": false
      }
    }
  }
}
```

---

## ログフォーマット

### JSON ログ形式

```json
{
  "timestamp": "2026-05-12T09:30:00.123Z",
  "sessionId": "sess_01ABCxyz",
  "userId": "kensan1969@gmail.com",
  "projectPath": "/home/user/my-project",
  "event": {
    "type": "tool_call",
    "tool": "Write",
    "arguments": {
      "file_path": "/home/user/my-project/src/auth.ts",
      "content_length": 1024
    },
    "result": "success",
    "duration_ms": 45
  },
  "model": "claude-sonnet-4-6",
  "context": {
    "tokensUsed": 2048,
    "phase": "Build"
  }
}
```

---

## クラウドへのログ転送

### AWS S3 への転送

```json
{
  "auditLog": {
    "output": {
      "s3": {
        "enabled": true,
        "bucket": "company-claude-audit-logs",
        "prefix": "claude-code/",
        "region": "ap-northeast-1",
        "encryption": "aws:kms",
        "kmsKeyId": "arn:aws:kms:ap-northeast-1:123456789:key/xxx"
      }
    }
  }
}
```

### CloudWatch Logs への転送

```json
{
  "auditLog": {
    "output": {
      "cloudwatch": {
        "enabled": true,
        "logGroupName": "/claude-code/audit",
        "logStreamPrefix": "session-",
        "region": "ap-northeast-1"
      }
    }
  }
}
```

### GCP Cloud Logging への転送

```json
{
  "auditLog": {
    "output": {
      "googleCloudLogging": {
        "enabled": true,
        "projectId": "your-project-id",
        "logName": "claude-code-audit"
      }
    }
  }
}
```

---

## ログ分析

### セッション別使用量の集計

```bash
# 今日のセッション一覧
jq -r 'select(.event.type == "session_start") | 
  [.timestamp, .userId, .projectPath] | @tsv' \
  ~/.claude/logs/audit/audit-$(date +%Y-%m-%d).json

# トークン使用量の集計
jq '[.context.tokensUsed] | add' \
  ~/.claude/logs/audit/audit-$(date +%Y-%m-%d).json
```

### 危険な操作の検出

```bash
# 危険なコマンドの実行履歴
jq -r 'select(
  .event.type == "tool_call" and
  .event.tool == "Bash" and
  (.event.arguments.command | test("rm -rf|sudo|curl.*evil"))
) | [.timestamp, .userId, .event.arguments.command] | @tsv' \
  ~/.claude/logs/audit/*.json
```

### ファイル変更の追跡

```bash
# 特定ファイルへの変更履歴
jq -r 'select(
  .event.type == "tool_call" and
  (.event.tool == "Write" or .event.tool == "Edit") and
  (.event.arguments.file_path | contains("auth"))
) | [.timestamp, .userId, .event.tool, .event.arguments.file_path] | @tsv' \
  ~/.claude/logs/audit/*.json
```

---

## コンプライアンス対応

### SOC 2 Type II

| 要件 | Claude Code での対応 |
|------|---------------------|
| アクセス制御 | SSO・RBAC・ネットワーク分離 |
| ログ記録 | 全操作の監査ログ（90日保持） |
| データ暗号化 | 転送中・保存中の暗号化 |
| インシデント対応 | 異常検知・アラート |

### ISO 27001

| 管理策 | 実装方法 |
|--------|---------|
| A.9 アクセス制御 | settings.json の permissions |
| A.12 運用セキュリティ | Hooks でのリアルタイム検知 |
| A.16 情報セキュリティインシデント管理 | 監査ログ＋アラート |
| A.18 コンプライアンス | ログの長期保存 |

### GDPR 対応

```json
{
  "gdpr": {
    "dataRetention": {
      "auditLogs": "90d",
      "sessionLogs": "30d",
      "modelCallLogs": "7d"
    },
    "anonymization": {
      "userIds": false,
      "fileContents": true
    },
    "dataResidency": {
      "region": "eu-west-1"
    }
  }
}
```

---

## アラート設定

### 異常検知アラート

```json
{
  "alerts": {
    "rules": [
      {
        "name": "危険なコマンド実行",
        "condition": "bash_command matches (rm -rf|sudo|chmod 777)",
        "severity": "critical",
        "action": "notify_security_team"
      },
      {
        "name": "異常なトークン使用",
        "condition": "session_tokens > 1000000",
        "severity": "warning",
        "action": "notify_admin"
      },
      {
        "name": "シークレットファイルアクセス",
        "condition": "file_path matches (.env|credentials|secret)",
        "severity": "high",
        "action": "block_and_notify"
      }
    ],
    "notifications": {
      "slack": {
        "webhook": "${SLACK_SECURITY_WEBHOOK}",
        "channel": "#security-alerts"
      },
      "email": {
        "recipients": ["security@your-company.com"]
      }
    }
  }
}
```

---

## ログ保持ポリシー

| ログ種別 | 推奨保持期間 | 法的要件（金融・医療） |
|---------|------------|-------------------|
| セッションログ | 30日 | 7年 |
| ツール実行ログ | 90日 | 7年 |
| セキュリティイベント | 1年 | 7年 |
| コンプライアンスログ | 3年 | 10年 |

---

## 関連ドキュメント

- [エンタープライズセットアップ](./01_エンタープライズセットアップ(EnterpriseSetup).md)
- [ネットワーク分離・セキュリティ](./03_ネットワーク分離・セキュリティ(NetworkSecurity).md)
- [セキュリティ診断](../04_インフラ・DevOps(InfraDevOps)/02_セキュリティ診断(SecurityAudit).md)
