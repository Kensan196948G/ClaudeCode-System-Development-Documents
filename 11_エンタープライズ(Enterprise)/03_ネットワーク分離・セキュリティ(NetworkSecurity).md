# 03 ネットワーク分離・セキュリティガイド

> **概要**: Claude Code のネットワーク分離設定、許可ホスト管理、セキュリティポリシーの実装方法を解説します。

---

## ネットワーク分離とは

Claude Code の **ネットワーク分離（Network Isolation）** は、AIが通信できるホストを制限し、意図しないデータ送信を防ぐセキュリティ機能です。

```
┌─────────────────────────────────────────────────────────────────┐
│               ネットワーク分離の動作                              │
│                                                                  │
│  Claude Code                                                     │
│       │                                                          │
│       ├── ✅ api.anthropic.com (許可)                             │
│       ├── ✅ github.com (許可)                                    │
│       ├── ✅ *.your-company.com (許可)                            │
│       ├── ❌ random-api.example.com (ブロック)                    │
│       └── ❌ attacker.com (ブロック)                              │
└─────────────────────────────────────────────────────────────────┘
```

---

## settings.json でのネットワーク設定

### 基本的な許可リスト設定

```json
{
  "network": {
    "isolation": "strict",
    "allowedHosts": [
      "api.anthropic.com",
      "api.github.com",
      "github.com",
      "*.your-company.com",
      "registry.npmjs.org",
      "pypi.org",
      "crates.io"
    ]
  }
}
```

### プロキシ設定

```json
{
  "network": {
    "proxy": {
      "http": "http://proxy.company.com:8080",
      "https": "https://proxy.company.com:8443",
      "noProxy": [
        "localhost",
        "127.0.0.1",
        "*.internal.company.com"
      ]
    }
  }
}
```

### 環境変数での設定

```bash
# プロキシ設定
export HTTP_PROXY=http://proxy.company.com:8080
export HTTPS_PROXY=https://proxy.company.com:8443
export NO_PROXY=localhost,127.0.0.1,*.internal.company.com

# ネットワーク分離モード
export CLAUDE_NETWORK_ISOLATION=strict
```

---

## ツール実行の権限管理

### Bash コマンドの制限

```json
{
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(npm install *)",
      "Bash(npm test *)",
      "Bash(npm run *)",
      "Read(*)",
      "Write(src/**)",
      "Write(tests/**)",
      "Glob(*)",
      "Grep(*)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(sudo *)",
      "Bash(curl *)",
      "Bash(wget *)",
      "Bash(ssh *)",
      "Bash(scp *)"
    ]
  }
}
```

### 承認が必要な操作

```json
{
  "permissions": {
    "requireApproval": [
      "Bash(git push *)",
      "Bash(git reset --hard *)",
      "Bash(npm publish *)",
      "Write(.env*)",
      "Write(*credentials*)",
      "Write(*secret*)"
    ]
  }
}
```

---

## シークレット管理

### 環境変数での秘密情報管理

```json
{
  "env": {
    "ANTHROPIC_API_KEY": "${ANTHROPIC_API_KEY}",
    "DATABASE_URL": "${DATABASE_URL}",
    "JWT_SECRET": "${JWT_SECRET}"
  }
}
```

### .env ファイルの保護

```json
{
  "permissions": {
    "deny": [
      "Read(.env)",
      "Read(.env.local)",
      "Read(.env.production)",
      "Write(.env*)"
    ]
  }
}
```

### Hooks でのシークレット検出

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "bash -c 'echo \"$CLAUDE_TOOL_INPUT\" | grep -qE \"(password|secret|key|token)\\s*=\\s*[^$]\" && echo \"[BLOCKED] シークレットを直接ハードコードしないでください\" && exit 2 || exit 0'"
      }]
    }]
  }
}
```

---

## セキュリティ監査

### 定期セキュリティスキャンの設定

```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "npx secretlint \"$CLAUDE_FILE_PATHS\" 2>&1"
      }]
    }]
  }
}
```

### 依存関係脆弱性チェック

```bash
# npm audit を自動実行
npm audit --audit-level=high

# または GitHub Advisory Database を使用
npx audit-ci --high
```

---

## コンテナ環境でのセキュリティ

### Docker でのサンドボックス実行

```dockerfile
FROM node:20-alpine

# 最小権限でユーザー作成
RUN addgroup -g 1001 -S claude && \
    adduser -S -u 1001 -G claude claude

WORKDIR /app
COPY --chown=claude:claude . .

# claude ユーザーで実行
USER claude

# ネットワーク制限（docker run 時に --network=none or カスタムネットワーク）
CMD ["claude-code", "--non-interactive"]
```

```bash
# 制限されたネットワークで実行
docker run \
  --network=restricted-network \
  --cap-drop=ALL \
  --security-opt=no-new-privileges \
  claude-code-image
```

---

## セキュリティチェックリスト

### デプロイ前チェック

```markdown
## Claude Code セキュリティチェックリスト

### ネットワーク
- [ ] allowedHosts に必要なホストのみ設定
- [ ] プロキシ経由でインターネットアクセスを管理
- [ ] 外部への直接接続をブロック

### 権限
- [ ] Bash コマンドに適切な制限を設定
- [ ] 危険なコマンド（rm -rf, sudo等）をブロック
- [ ] シークレットファイルへの書き込みを禁止

### シークレット
- [ ] API キーを環境変数で管理（ハードコードなし）
- [ ] .env ファイルを .gitignore に追加
- [ ] Hooks でシークレット検出を自動化

### 監査
- [ ] 監査ログを有効化
- [ ] ログを安全なストレージに保存
- [ ] ログの保存期間を設定（最低90日）
```

---

## インシデント対応

### セキュリティインシデント発生時

```bash
# 1. 即時に Claude Code を停止
# Ctrl+C または セッション終了

# 2. 監査ログを確認
cat ~/.claude/logs/audit/*.log | grep "SECURITY"

# 3. 問題のある操作を特定
git log --since="1 hour ago" --oneline

# 4. 不正な変更を元に戻す
git revert HEAD~N

# 5. APIキーをローテート
# Anthropic コンソールで API キーを無効化し再発行
```

---

## 関連ドキュメント

- [監査ログ・コンプライアンス](./04_監査ログ・コンプライアンス(AuditCompliance).md)
- [エンタープライズセットアップ](./01_エンタープライズセットアップ(EnterpriseSetup).md)
- [Hooks 設定ガイド](../02_起動・設定(StartupConfig)/06_Hooks設定ガイド(HooksConfig).md)
- [settings.json 設定ガイド](../02_起動・設定(StartupConfig)/07_settings_json設定ガイド(SettingsJson).md)
