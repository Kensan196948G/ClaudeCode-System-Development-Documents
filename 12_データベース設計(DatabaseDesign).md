# 12 データベース設計（Database Design）

## Claude Code 起動コマンド

```bash
claude --dangerously-skip-permissions
```

## プロンプト指示

```
以下の要件でデータベーススキーマを設計・実装してください。

【要件】
- DB エンジン: [PostgreSQL / MySQL / SQLite / MongoDB]
- ORM: [Prisma / TypeORM / SQLAlchemy / GORM / Drizzle]
- サービス概要: [どんなサービスか]
- 主要エンティティ: [ユーザー / 商品 / 注文 / など]

【設計要件（Architect / DevAPI Agent が担当）】
- 正規化（第3正規形を基本とする）
- インデックス設計（クエリパターンに基づく）
- 外部キー制約・ユニーク制約の設定
- Soft Delete の採用可否を検討する
- 監査ログ（created_at / updated_at / deleted_at）を全テーブルに追加する
- マルチテナント対応が必要か検討する

【実行してほしいこと】
1. ER 図（Mermaid）でスキーマ設計を提示して承認を得る
2. マイグレーションファイルを生成する
3. シードデータ（開発・テスト用）を作成する
4. 主要クエリパターンのインデックスを設定する
5. EXPLAIN ANALYZE でクエリプランを確認する
6. スキーマ設計の意思決定を docs/database.md に記載する
7. git commit（feat: データベーススキーマの初期設計）する

【完了基準】
- マイグレーションが正常に適用される
- シードデータが正常に投入される
- 主要クエリが適切なインデックスを使用している
```

## 使用場面

- 新規サービスのDB設計
- 既存DBのリファクタリング
- パフォーマンス改善のためのインデックス追加

## ポイント

- Mermaid ER 図で承認を得てから実装することでやり直しを防ぐ
