# 04 ナレッジベース管理（Knowledge Base Management）

---

## 概要

チームの知識・ノウハウを体系的に蓄積・活用するナレッジベースの  
構築・運用を Claude Code が支援するためのプロンプトです。

---

## Claude Code 起動コマンド

```
以下のナレッジベース管理タスクを実行してください。

【タスク種別】
[ ] 障害対応記録の作成（ポストモーテム）
[ ] 開発ノウハウのドキュメント化
[ ] FAQ・トラブルシューティングガイドの更新
[ ] オンボーディング資料の更新
[ ] 意思決定記録（ADR）の作成

【対象情報】
[記録する内容・対象の説明]

Markdown形式で作成し、検索しやすいようにタグ・カテゴリを付与してください。
```

---

## ナレッジベース構造

```
knowledge-base/
├── adr/                    # アーキテクチャ決定記録
│   ├── ADR-001_技術スタック選定.md
│   └── ADR-002_DB設計方針.md
├── runbooks/               # 運用手順書
│   ├── デプロイ手順.md
│   └── 障害対応手順.md
├── postmortems/            # 障害振り返り
│   └── 2026-01_DBダウン事例.md
├── how-to/                 # 開発ノウハウ
│   ├── ローカル環境構築.md
│   └── テスト実行方法.md
└── faq/                    # よくある質問
    └── 開発環境FAQ.md
```

---

## ADR（アーキテクチャ決定記録）テンプレート

```markdown
# ADR-[番号]: [決定タイトル]

## ステータス
[提案中 / 採用 / 廃止 / 代替案で置き換え]

## コンテキスト
この決定が必要になった背景・問題を説明する。

## 決定内容
何を決定したか。

## 根拠
なぜその決定をしたか。代替案と比較した理由。

## 代替案
検討したが採用しなかった選択肢と、採用しなかった理由。

## 影響
この決定によりどんな影響があるか（メリット・デメリット）。

## 更新履歴
| 日付 | 更新者 | 内容 |
|------|--------|------|
| 2026-01-01 | @author | 初版作成 |
```

---

## ポストモーテム（障害振り返り）テンプレート

```markdown
# ポストモーテム: [障害名]

## 概要
- **発生日時**: YYYY-MM-DD HH:MM
- **復旧日時**: YYYY-MM-DD HH:MM
- **影響範囲**: [ユーザー数 / サービス]
- **重大度**: [P1 / P2 / P3]

## タイムライン
| 時刻 | 出来事 |
|------|--------|
| HH:MM | アラート発報 |
| HH:MM | 原因特定 |
| HH:MM | 対応開始 |
| HH:MM | 復旧完了 |

## 根本原因
[技術的な根本原因の説明]

## 対応内容
[実施した対応]

## 再発防止策
| 対策 | 担当 | 期限 | ステータス |
|------|------|------|----------|
| | | | |

## 学び
[チームとして学んだこと]
```

---

## ナレッジ検索の最適化

### タグ付け規約

```yaml
# タグカテゴリ
categories:
  - backend
  - frontend
  - infra
  - security
  - database
  - troubleshooting
  - how-to
  - decision

# 使用例
tags: [backend, database, troubleshooting]
```

### 全文検索設定（GitHub Actions + Algolia）

```yaml
# .github/workflows/update-search-index.yml
name: Update Search Index
on:
  push:
    paths: ['knowledge-base/**']
jobs:
  update-index:
    runs-on: ubuntu-latest
    steps:
      - name: Crawl and index
        uses: algolia/algoliasearch-crawler-github-actions@v1
        with:
          crawler-user-id: ${{ secrets.ALGOLIA_CRAWLER_USER_ID }}
          crawler-api-key: ${{ secrets.ALGOLIA_CRAWLER_API_KEY }}
```

---

## 関連ドキュメント

- [ドキュメント生成](./01_ドキュメント生成(DocGeneration).md)
- [チームオンボーディング](./05_チームオンボーディング(TeamOnboarding).md)
- [インシデント対応](../06_保守・移行(MaintenanceMigration)/03_インシデント対応(IncidentResponse).md)
