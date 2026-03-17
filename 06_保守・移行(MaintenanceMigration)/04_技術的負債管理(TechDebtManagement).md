# 04 技術的負債管理（Technical Debt Management）

---

## 概要

技術的負債を可視化・計画的に返済するための管理プロセスを  
Claude Code が支援するためのプロンプトです。

---

## Claude Code 起動コマンド

```
以下のコードベースの技術的負債を分析・管理計画を作成してください。

【対象】
[リポジトリ名 or ディレクトリ]

【分析観点】
1. コード品質負債（複雑度・重複・命名）
2. アーキテクチャ負債（設計の歪み・依存関係）
3. テスト負債（カバレッジ不足・壊れやすいテスト）
4. インフラ負債（古い依存関係・設定ハードコード）
5. ドキュメント負債（未記載・古い情報）

各負債を重要度・解決コストで評価し、返済ロードマップを作成してください。
```

---

## 技術的負債の分類

### 意図的な負債（Deliberate Debt）

```
特徴: 期限優先で意識的に妥協した実装
例:  - リリース期限のために一時的な実装
     - プロトタイプのコードをそのまま本番投入
管理: TODO/FIXME コメントで記録、次スプリントで返済計画

// TODO: [TECH-DEBT-001] 認証ロジックをミドルウェアに分離する
//        期限: 2026-Q1 担当: @developer
```

### 非意図的な負債（Inadvertent Debt）

```
特徴: 知識不足・設計スキル不足による蓄積
例:  - ベストプラクティスを知らずに実装
     - 仕様変更に追随できなかった設計
管理: 定期的なコード解析で検出
```

---

## 負債スコアリング

| 項目 | 重要度 (1-5) | 解決コスト (1-5) | 優先度スコア |
|------|------------|----------------|------------|
| 重複コード（DRY違反） | 3 | 2 | 高 |
| 循環依存 | 5 | 4 | 高 |
| テストカバレッジ不足 | 4 | 3 | 高 |
| 古い依存ライブラリ | 4 | 2 | 高 |
| 命名規則の不統一 | 2 | 3 | 低 |

> **優先度スコア = 重要度 × (6 - 解決コスト)**

---

## 返済ロードマップ テンプレート

```markdown
## 技術的負債 返済ロードマップ

### 今スプリント（即対応）
- [ ] TECH-DEBT-001: 認証ロジックのミドルウェア分離
- [ ] TECH-DEBT-002: データベース接続プールの設定見直し

### 今四半期（Q1）
- [ ] TECH-DEBT-005: テストカバレッジ 60% → 80% 向上
- [ ] TECH-DEBT-007: Node.js 16 → 20 アップグレード

### 来四半期（Q2）
- [ ] TECH-DEBT-012: モノリスの認証サービス分離
- [ ] TECH-DEBT-015: APIレスポンス形式の統一

### バックログ（将来）
- [ ] TECH-DEBT-020: フロントエンドのTypeScript化
```

---

## 自動検出 CI 設定

```yaml
# .github/workflows/tech-debt-check.yml
name: Technical Debt Check
on:
  pull_request:
  schedule:
    - cron: '0 9 * * 1'  # 毎週月曜

jobs:
  debt-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Count TODO/FIXME
        run: |
          echo "## 技術的負債 TODO/FIXME 件数"
          grep -rn "TODO\|FIXME\|HACK\|XXX" --include="*.ts" --include="*.py" . \
            | grep -v "node_modules\|.git" \
            | wc -l
      - name: SonarQube Scan
        uses: SonarSource/sonarcloud-github-action@master
        env:
          SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
```

---

## 関連ドキュメント

- [リファクタリング](../03_開発シナリオ(DevelopmentScenarios)/04_リファクタリング(Refactoring).md)
- [依存関係更新](./02_依存関係更新(DependencyUpdate).md)
- [コード解析](../03_開発シナリオ(DevelopmentScenarios)/07_コード解析(CodeAnalysis).md)
