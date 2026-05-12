# 01 エンタープライズセットアップガイド

> **対象**: 組織全体で Claude Code を導入・管理するチーム向け。SSO・ポリシー・権限管理・監査ログの設定方法を解説します。

---

## エンタープライズ機能の概要

| 機能 | 説明 |
|------|------|
| **SSO / SAML 認証** | 組織の認証基盤と統合 |
| **チームポリシー** | 組織全体の設定を一元管理 |
| **監査ログ** | 全操作の記録・コンプライアンス対応 |
| **ネットワーク分離** | 承認されたホストのみに通信制限 |
| **権限管理** | ロールベースのアクセス制御 |
| **AWS Bedrock / GCP Vertex 対応** | 自社クラウドインフラでのホスティング |

---

## 認証設定

### SSO / SAML の設定

```json
// .claude/settings.json（組織共通設定）
{
  "auth": {
    "type": "sso",
    "provider": "okta",
    "ssoUrl": "https://your-org.okta.com/sso/saml",
    "enforceSSO": true
  }
}
```

### SCIM（自動プロビジョニング）

```json
{
  "scim": {
    "enabled": true,
    "endpoint": "https://api.anthropic.com/scim/v2",
    "token": "${SCIM_TOKEN}"
  }
}
```

---

## チームポリシー設定

### 組織共通の settings.json

```json
{
  "organizationPolicy": {
    "model": "claude-sonnet-4-6",
    "maxTokensPerSession": 500000,
    "allowedTools": [
      "Read", "Write", "Edit", "Bash", "Glob", "Grep"
    ],
    "deniedTools": [
      "WebFetch"
    ],
    "requireApprovalFor": [
      "Bash(rm *)",
      "Bash(sudo *)",
      "Bash(git push --force *)"
    ],
    "auditLogging": {
      "enabled": true,
      "destination": "s3://company-audit-logs/claude-code/"
    }
  }
}
```

### ロールベースの権限設定

```json
{
  "roles": {
    "developer": {
      "allowedTools": ["Read", "Write", "Edit", "Bash(npm *)", "Bash(git *)"],
      "model": "claude-sonnet-4-6"
    },
    "senior-developer": {
      "allowedTools": ["*"],
      "model": "claude-opus-4-7",
      "requireApprovalFor": ["Bash(rm *)"]
    },
    "readonly": {
      "allowedTools": ["Read", "Grep", "Glob"],
      "model": "claude-haiku-4-5-20251001"
    }
  }
}
```

---

## ネットワーク設定

```json
{
  "network": {
    "isolation": "strict",
    "allowedHosts": [
      "api.anthropic.com",
      "github.com",
      "*.your-company.com",
      "registry.npmjs.org"
    ],
    "blockExternalAccess": true,
    "proxyUrl": "http://proxy.your-company.com:8080"
  }
}
```

詳細は [ネットワーク分離・セキュリティ](./03_ネットワーク分離・セキュリティ(NetworkSecurity).md) を参照。

---

## 監査ログ設定

```json
{
  "auditLog": {
    "enabled": true,
    "level": "detailed",
    "events": [
      "tool_call",
      "file_write",
      "bash_execute",
      "session_start",
      "session_end"
    ],
    "destination": {
      "type": "s3",
      "bucket": "company-audit-logs",
      "prefix": "claude-code/",
      "region": "ap-northeast-1"
    },
    "retention": "90d"
  }
}
```

詳細は [監査ログ・コンプライアンス](./04_監査ログ・コンプライアンス(AuditCompliance).md) を参照。

---

## 大規模展開の手順

### ステップ1: 組織設定の準備

```bash
# 組織共通設定ファイルの作成
mkdir -p /etc/claude-code/
cat > /etc/claude-code/org-settings.json << 'EOF'
{
  "model": "claude-sonnet-4-6",
  "auditLogging": { "enabled": true },
  "network": { "isolation": "strict" }
}
EOF
```

### ステップ2: CLAUDE.md テンプレートの配布

```bash
# 全プロジェクトに共通の CLAUDE.md テンプレートを配布
# GitHub の .github/CLAUDE_TEMPLATE.md として管理
```

### ステップ3: CI/CD 統合

```yaml
# .github/workflows/claude-code.yml
- name: Setup Claude Code
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
    CLAUDE_ORG_ID: ${{ secrets.CLAUDE_ORG_ID }}
  run: |
    npm install -g @anthropic-ai/claude-code
    claude-code verify-auth
```

### ステップ4: 使用量モニタリング

```json
{
  "monitoring": {
    "enabled": true,
    "metricsEndpoint": "https://metrics.your-company.com/claude",
    "alerts": {
      "tokenUsageThreshold": 1000000,
      "costThreshold": 1000
    }
  }
}
```

---

## コスト管理

### 使用量制限の設定

```json
{
  "quotas": {
    "perUser": {
      "dailyTokens": 100000,
      "monthlyTokens": 2000000,
      "dailyCost": 10.0
    },
    "perTeam": {
      "monthlyTokens": 20000000,
      "monthlyCost": 500.0
    }
  }
}
```

### コスト最適化の推奨設定

| 施策 | 効果 |
|------|------|
| Prompt Caching 有効化 | キャッシュヒット率 60-80% でコスト大幅削減 |
| Haiku を Monitor Loop に使用 | 監視タスクのコストを 80% 削減 |
| Batch API の活用 | 大量処理を 50% 割引で実行 |
| モデルの適切な選択 | Sonnet/Haiku で Opus の 10〜30 倍安価 |

---

## オンボーディング

### 新メンバーへのチェックリスト

```markdown
## Claude Code エンタープライズ利用開始チェックリスト

- [ ] SSO アカウントの取得
- [ ] 組織の settings.json の確認
- [ ] セキュリティポリシーの確認
- [ ] 禁止操作の把握（Bash 実行制限等）
- [ ] 監査ログの記録対象操作の理解
- [ ] 使用量クォータの確認
- [ ] エスカレーションフローの把握
```

---

## 関連ドキュメント

- [Bedrock・Vertex デプロイ](./02_Bedrock・Vertexデプロイ(BedrockVertex).md)
- [ネットワーク分離・セキュリティ](./03_ネットワーク分離・セキュリティ(NetworkSecurity).md)
- [監査ログ・コンプライアンス](./04_監査ログ・コンプライアンス(AuditCompliance).md)
- [settings.json 設定ガイド](../02_起動・設定(StartupConfig)/07_settings_json設定ガイド(SettingsJson).md)
