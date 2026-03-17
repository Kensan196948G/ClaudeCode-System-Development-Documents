# 03 設計ドキュメント作成（Design Document Creation）

---

## 概要

システム設計・機能設計の標準ドキュメントを Claude Code が自動生成するためのプロンプトです。

---

## Claude Code 起動コマンド

```
以下の設計ドキュメントを作成してください。

【ドキュメント種別】
[ ] システム設計書（アーキテクチャ全体）
[ ] 機能設計書（個別機能の詳細）
[ ] API設計書（OpenAPI形式）
[ ] データベース設計書（ER図 + テーブル定義）
[ ] シーケンス図（処理フロー）

【対象】
[機能名・システム名]

【読者】
[ ] 開発者
[ ] 運用担当者
[ ] ステークホルダー（非技術者）

Markdown形式で作成し、図はMermaid記法で記述してください。
```

---

## ドキュメントテンプレート集

### システム設計書テンプレート

```markdown
# [システム名] システム設計書

## 1. 概要
### 1.1 目的
### 1.2 スコープ
### 1.3 前提条件・制約

## 2. システムアーキテクチャ
### 2.1 システム構成図（Mermaid）
### 2.2 コンポーネント説明
### 2.3 データフロー

## 3. 技術選定
| 項目 | 採用技術 | 採用理由 |
|------|---------|---------|

## 4. 非機能要件
### 4.1 性能要件
### 4.2 可用性要件
### 4.3 セキュリティ要件

## 5. 移行・展開計画
## 6. リスクと対策
## 7. 更新履歴
```

---

### シーケンス図（Mermaid記法）

```markdown
# ログイン処理 シーケンス図

\`\`\`mermaid
sequenceDiagram
    actor User
    participant Browser
    participant API
    participant DB
    participant Cache

    User->>Browser: メールアドレス・パスワード入力
    Browser->>API: POST /auth/login
    API->>DB: ユーザー情報取得
    DB-->>API: ユーザーレコード
    API->>API: パスワード検証（bcrypt）
    API->>Cache: セッション保存
    API-->>Browser: JWTトークン返却
    Browser-->>User: ダッシュボードへリダイレクト
\`\`\`
```

---

### ER図（Mermaid記法）

```markdown
\`\`\`mermaid
erDiagram
    USER {
        uuid id PK
        string email UK
        string password_hash
        string name
        enum role
        timestamp created_at
        timestamp updated_at
    }
    ORDER {
        uuid id PK
        uuid user_id FK
        enum status
        decimal total_amount
        timestamp created_at
    }
    ORDER_ITEM {
        uuid id PK
        uuid order_id FK
        uuid product_id FK
        int quantity
        decimal price
    }

    USER ||--o{ ORDER : "places"
    ORDER ||--|{ ORDER_ITEM : "contains"
\`\`\`
```

---

## ドキュメント品質チェック

```
必須項目:
- [ ] 目的・スコープが明確
- [ ] 読者が明示されている
- [ ] 図・表が適切に使用されている
- [ ] 用語集・略語が定義されている
- [ ] 更新履歴が記録されている
- [ ] レビュー済みのマークがある

品質基準:
- 非技術者が読んで概要を理解できる（ステークホルダー向け）
- 開発者が迷わず実装できる（技術者向け）
```

---

## GitHub Pages への自動公開

```yaml
# .github/workflows/publish-docs.yml
name: Publish Documentation
on:
  push:
    branches: [main]
    paths: ['docs/**', '**.md']

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup MkDocs
        run: pip install mkdocs mkdocs-material
      - name: Build docs
        run: mkdocs build
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./site
```

---

## 関連ドキュメント

- [ドキュメント生成](./01_ドキュメント生成(DocGeneration).md)
- [アーキテクチャ概要](../01_システム概要(SystemOverview)/02_アーキテクチャ概要(ArchitectureOverview).md)
- [コーディング規約](./02_コーディング規約(CodingStandards).md)
