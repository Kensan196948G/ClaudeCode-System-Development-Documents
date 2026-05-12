# 08 カスタムスキル（Custom Skills）開発ガイド

> **概要**: Claude Code のスラッシュコマンド（/スキル名）をカスタム定義する方法と、プロジェクト固有の自動化コマンドを作成する手順を解説します。

---

## カスタムスキルとは

カスタムスキルは `.claude/commands/` ディレクトリに Markdown ファイルとして定義する**プロジェクト固有のスラッシュコマンド**です。

```
.claude/
└── commands/
    ├── review.md      → /review コマンドとして呼び出し可能
    ├── deploy.md      → /deploy コマンドとして呼び出し可能
    ├── hotfix.md      → /hotfix コマンドとして呼び出し可能
    └── db-migrate.md  → /db-migrate コマンドとして呼び出し可能
```

---

## カスタムスキルのファイル形式

```markdown
---
name: スキル名
description: スキルの説明（/help で表示される）
---

# スキル名

## 概要
このスキルが何をするか

## 実行手順
1. ステップ1
2. ステップ2
...

## 完了条件
- 条件1を満たしていること
```

---

## 組み込みスキルの一覧

Claude Code には以下のスキルが事前定義されています：

| スキル | 用途 |
|-------|------|
| `/review` | PRのコードレビュー |
| `/init` | CLAUDE.md の初期化 |
| `/security-review` | セキュリティレビュー |
| `/loop` | 繰り返し実行 |
| `/schedule` | スケジュール実行 |
| `/fast` | Fast Mode 切り替え |
| `/plan` | Plan Mode 開始 |
| `/ultrareview` | マルチエージェントクラウドレビュー |

---

## カスタムスキルの作成例

### /hotfix スキル

```markdown
---
name: hotfix
description: 本番環境の緊急バグ修正フロー
---

# Hotfix フロー

## 前提確認
1. main ブランチの最新を pull
2. 影響を受けているユーザー数を確認

## 実行手順
1. `hotfix/[issue-number]-[short-description]` ブランチを作成
2. バグの根本原因を特定
3. 最小限の修正を実装（関係ないリファクタリングは行わない）
4. テストを追加（バグの再現 + 修正後の動作確認）
5. レビュー用 PR を作成（タイトルに [HOTFIX] を付ける）
6. CI 通過を確認
7. マージ後にデプロイ

## 完了条件
- バグが再現しないことをテストで証明
- CI が全て通過
- PR が作成されマージ待ち状態
```

### /db-migrate スキル

```markdown
---
name: db-migrate
description: データベースマイグレーションの安全な実行
---

# DB マイグレーション実行フロー

## 事前チェック
1. 現在のマイグレーション状態を確認
2. バックアップが存在することを確認
3. ロールバック手順を明記

## 実行手順
1. マイグレーションファイルを確認
2. ステージング環境でテスト実行
3. 影響を受けるデータ量を確認
4. ダウンタイムが必要か判断
5. 本番実行
6. 実行後の検証

## ロールバック手順
問題発生時は直ちに rollback コマンドを実行
```

### /deploy スキル

```markdown
---
name: deploy
description: ステージングから本番へのデプロイフロー
---

# デプロイフロー

## チェックリスト
- [ ] CI が全て通過
- [ ] E2E テストが通過
- [ ] ステージング環境での動作確認
- [ ] リリースノートが作成済み

## デプロイ手順
1. main ブランチの最新状態を確認
2. バージョンタグを作成
3. デプロイコマンド実行
4. ヘルスチェック確認
5. 主要機能の動作確認
6. メトリクスダッシュボード確認（最初の15分）

## ロールバック基準
以下の場合は即座にロールバック：
- エラーレートが 1% を超える
- レスポンスタイムが 3 倍以上になる
```

---

## 高度なスキル：引数の受け取り

スキルファイルで `$ARGUMENTS` を使うと引数を受け取れます：

```markdown
---
name: issue-fix
description: 指定Issueを修正する（例: /issue-fix 123）
---

# Issue #$ARGUMENTS の修正

## 手順
1. GitHub から Issue #$ARGUMENTS の内容を取得
2. 関連するコードを調査
3. 修正実装
4. テスト追加
5. PR 作成（クローズ: #$ARGUMENTS を PR に含める）
```

呼び出し方:
```bash
/issue-fix 123
```

---

## スキルのベストプラクティス

### 良いスキル設計の原則

| 原則 | 内容 |
|------|------|
| **単一責任** | 1つのスキルは1つの明確なタスクを担当 |
| **冪等性** | 複数回実行しても安全 |
| **終了条件明確** | 「完了」の定義を明示 |
| **ロールバック** | 問題発生時の対処を含める |
| **チェックリスト** | 実行前の確認事項を列挙 |

### 避けるべきパターン

```markdown
# 悪い例: 過度に複雑なスキル
- 10以上のステップ → 3〜7ステップに分割
- 曖昧な完了条件 → 具体的な検証手順を含める
- ロールバックなし → 必ず復旧手順を追加
```

---

## グローバルスキルとプロジェクトスキル

| 種類 | 場所 | スコープ |
|------|------|---------|
| グローバルスキル | `~/.claude/commands/` | 全プロジェクト共通 |
| プロジェクトスキル | `.claude/commands/` | 該当プロジェクトのみ |

```bash
# グローバルスキルの作成
mkdir -p ~/.claude/commands/
cat > ~/.claude/commands/my-global-skill.md << 'EOF'
---
name: my-global-skill
description: 全プロジェクト共通の便利スキル
---

# 処理内容...
EOF
```

---

## settings.json でのスキル制御

```json
{
  "customCommands": {
    "enabled": true,
    "paths": [
      ".claude/commands",
      "~/.claude/commands"
    ]
  },
  "permissions": {
    "allow": [
      "Bash(git *)",
      "Bash(npm *)",
      "Read(*)",
      "Write(*)"
    ]
  }
}
```

---

## 関連ドキュメント

- [Hooks 設定ガイド](../02_起動・設定(StartupConfig)/06_Hooks設定ガイド(HooksConfig).md)
- [CLAUDE.md 設定ガイド](../02_起動・設定(StartupConfig)/05_CLAUDE_MD設定ガイド(CLAUDEMDConfig).md)
- [テンプレート commands/](../templates/.claude/commands/)
