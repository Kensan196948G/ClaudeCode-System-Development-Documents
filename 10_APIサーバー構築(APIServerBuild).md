# 10 API サーバー構築（API Server Build）

## Claude Code 起動コマンド

```bash
claude --dangerously-skip-permissions
```

## プロンプト指示

```
以下の仕様で REST API サーバーを構築してください。

【API 概要】
- サービス名: [SERVICE_NAME]
- フレームワーク: [Express / Fastify / FastAPI / Gin / Hono など]
- データベース: [PostgreSQL / MySQL / MongoDB / SQLite]
- 認証方式: [JWT / OAuth2 / API Key / Session]

【エンドポイント設計（DevAPI / Architect Agent が担当）】
```
[エンドポイント一覧を箇条書きで記載]
例:
GET    /api/v1/users           - ユーザー一覧取得
POST   /api/v1/users           - ユーザー作成
GET    /api/v1/users/:id       - ユーザー詳細取得
PUT    /api/v1/users/:id       - ユーザー更新
DELETE /api/v1/users/:id       - ユーザー削除
```

【実装要件】
- OpenAPI 3.0 仕様書を自動生成する
- バリデーション（Zod / Pydantic / go-playground/validator）を実装する
- エラーレスポンスを統一する
- レート制限を実装する
- ヘルスチェックエンドポイント（GET /health）を実装する
- ロギング（構造化ログ）を設定する

【実行してほしいこと】
1. 設計を Agent Teams で議論して承認を得る
2. プロジェクト構造を作成する（Controller / Service / Repository 層）
3. 各エンドポイントを実装する
4. 統合テストを作成する
5. Docker / docker-compose.yml を作成する
6. OpenAPI 仕様書（openapi.yaml）を生成する
7. git commit（feat: API サーバーの初期実装）する
```

## 使用場面

- マイクロサービスの新規構築
- モバイルアプリ向けバックエンド作成
- 社内ツールの API 化

## ポイント

- エンドポイント一覧を事前に整理しておくと実装精度が大幅に向上する
