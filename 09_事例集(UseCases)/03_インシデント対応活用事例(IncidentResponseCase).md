# 03 インシデント対応での活用事例（Incident Response Case）

---

## インシデント概要

| 項目 | 内容 |
|------|------|
| **発生日時** | 深夜 02:30（JST） |
| **影響範囲** | 本番APIサーバー（レスポンス遅延 8000ms → 正常値 200ms） |
| **根本原因** | データベースクエリの N+1 問題（デプロイ直後から発生） |
| **解決時間** | 45分（通常の手動対応: 2〜4時間） |
| **使用モデル** | claude-opus-4-6（原因調査）→ claude-sonnet-4-5（修正実装） |

---

## Claude Code を使った対応フロー

### フェーズ 1: 原因調査（15分）

```
# Claude Code へのプロンプト
緊急インシデント対応モードで起動してください。
本番APIのレスポンスが 8000ms になっています。
直近のデプロイ差分（git diff HEAD~1）を確認して原因を特定してください。
```

**Claude の分析結果:**
```markdown
原因特定:
- src/services/UserService.ts の getUsers() メソッドに N+1 問題
- ユーザー一覧取得時に各ユーザーのロール情報を個別クエリで取得
- 100ユーザーの場合: 101回のクエリが発生

問題のコード（行 45-58）:
  const users = await User.findAll();
  for (const user of users) {
    user.roles = await Role.findAll({ where: { userId: user.id } });
  }

修正案: include オプションでJOIN クエリに変更
```

### フェーズ 2: 修正実装（20分）

```
# 修正を依頼
特定した N+1 問題を修正してください。
テストが通過することを確認してから、修正内容の差分を表示してください。
```

**修正後のコード:**
```typescript
const users = await User.findAll({
  include: [{ model: Role }]  // JOIN で一括取得
});
```

**テスト結果:** 全テスト通過 ✅

### フェーズ 3: 緊急デプロイ判断（10分）

```
# デプロイ前の最終確認を依頼
修正の影響範囲を確認してください。
他のサービスへの影響と、ロールバック手順も合わせて提示してください。
```

---

## 教訓

### Claude Code が有効だった点

1. **コードベースの即時分析**: 15分で原因特定（通常30〜60分）
2. **テスト付き修正**: 人間が慌てているとテストを省きがちだが、Claude は必ず実行
3. **ロールバック手順の自動提示**: 判断に必要な情報を漏れなく提供

### 注意点

1. **本番デプロイは自動承認しない**: `settings.json` で `.*prod.*deploy.*` を `auto: false` に設定済み
2. **モデルを状況に応じて切替**: 分析は opus（深い理解）、実装は sonnet（速度重視）

---

## この事例で使った設定

```json
// .claude/settings.json の関連部分
{
  "autoApprove": {
    "rules": [
      { "tool": "bash", "pattern": ".*prod.*deploy.*", "auto": false },
      { "tool": "bash", "pattern": "git log.*",         "auto": true  }
    ]
  }
}
```

---

## 参考

- [インシデント対応プロンプト](../06_保守・移行(MaintenanceMigration)/03_インシデント対応(IncidentResponse).md)
- [settings.json 設定ガイド](../02_起動・設定(StartupConfig)/07_settings_json設定ガイド(SettingsJson).md)
