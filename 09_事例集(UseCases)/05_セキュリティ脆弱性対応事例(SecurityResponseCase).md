# 05 セキュリティ脆弱性対応事例（Security Response Case）

---

## 概要

| 項目 | 内容 |
|------|------|
| **発生事象** | 依存ライブラリの Critical CVE 発覚（CVSS 9.8） |
| **影響範囲** | 本番 API サーバー全体（認証バイパスの可能性） |
| **対応時間** | 2.5時間（通常の手動対応: 8〜16時間） |
| **使用モデル** | claude-opus-4-6（セキュリティ分析）→ claude-sonnet-4-5（修正） |

---

## セキュリティ対応での Claude Code 活用フロー

### フェーズ 1: 脆弱性の影響範囲特定（30分）

```
# セキュリティエージェントとして起動
security-agentとして以下のセキュリティ診断を実行してください：

1. npm audit / pip audit を実行して既知の脆弱性を全て列挙
2. CVE-2025-XXXX（jsonwebtoken の認証バイパス脆弱性）の影響コードを特定
3. 攻撃ベクター・影響範囲・緊急度を評価
4. 修正方針を提案（アップデート/パッチ/ワークアラウンド）
```

**Claude の分析結果:**
```markdown
## セキュリティ診断結果

### Critical（即時対応必須）
- jsonwebtoken@8.5.1 → CVE-2025-XXXX（認証バイパス）
  - 影響: /api/auth/* 全エンドポイント
  - 攻撃ベクター: 細工した JWT トークンで任意ユーザーとして認証可能
  - 修正: jsonwebtoken@9.0.2 以上へアップデート

### High
- express@4.18.1 → CVE-2025-YYYY（ReDoS）
  - 影響: 全リクエスト処理
  - 修正: express@4.19.0 以上へアップデート

### 影響するファイル（7本）
- src/middleware/auth.ts
- src/api/users.ts
- src/api/admin.ts
（他4本）
```

---

### フェーズ 2: 修正実装（1時間）

```
# 修正を実行
特定した脆弱性を修正してください：
1. jsonwebtoken を 9.0.2 に更新
2. 既存の JWT 検証ロジックが新バージョンのAPIに対応しているか確認・修正
3. セキュリティテストを追加（不正なトークンが拒否されることを確認）
4. 全既存テストが通過することを確認
```

**修正内容:**
```typescript
// Before（脆弱）
jwt.verify(token, secret, { algorithms: ['HS256', 'none'] });

// After（修正済み）
jwt.verify(token, secret, { algorithms: ['HS256'] });
// 'none' アルゴリズムを明示的に除外
```

---

### フェーズ 3: 検証・報告（1時間）

```
セキュリティ対応の最終確認レポートを作成してください：
- 修正前後の npm audit 結果
- 追加したセキュリティテストの一覧
- 影響を受けた可能性のある期間と推奨アクション
- 再発防止策（依存関係の自動監視設定）
```

---

## 再発防止のための自動化設定

### GitHub Actions で依存関係を自動監視

```yaml
# .github/workflows/security-scan.yml
name: セキュリティスキャン
on:
  schedule:
    - cron: '0 9 * * 1'  # 毎週月曜 9:00
  push:
    paths: ['package.json', 'package-lock.json', 'requirements.txt']

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm audit --audit-level=high
      # High 以上の脆弱性があれば CI が失敗する
```

### Hooks での依存関係変更時チェック

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": { "tool_name": "bash", "tool_input": "npm install.*" },
        "hooks": [{
          "type": "command",
          "command": "npm audit --audit-level=moderate 2>&1 | tail -10",
          "on_failure": "warn"
        }]
      }
    ]
  }
}
```

---

## 教訓

| 教訓 | 詳細 |
|------|------|
| **CVE 対応は speed が最重要** | Claude を使うと影響調査が10倍速い |
| **修正と同時にテストを追加** | 人間が急いでいるとテストを忘れがち |
| **自動監視の設定** | 次回の CVE を事前に検出できる体制を整備 |

---

## 参考

- [セキュリティ診断プロンプト](../04_インフラ・DevOps(InfraDevOps)/02_セキュリティ診断(SecurityAudit).md)
- [CI/CD構築](../04_インフラ・DevOps(InfraDevOps)/01_CI_CD構築(CICDSetup).md)
