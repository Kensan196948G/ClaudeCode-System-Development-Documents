# 04 環境構築（Environment Setup）

---

## 概要

開発・ステージング・本番環境の構築を Claude Code が自律的に実行するためのプロンプトです。

---

## Claude Code 起動コマンド

```
以下の環境構築タスクを実行してください。

【対象環境】
[ ] 開発（development）
[ ] ステージング（staging）
[ ] 本番（production）

【技術スタック】
- OS: [Ubuntu 22.04 / Amazon Linux 2023 など]
- ランタイム: [Node.js 20 / Python 3.11 など]
- データベース: [PostgreSQL 15 / MySQL 8 など]
- キャッシュ: [Redis 7 など]
- コンテナ: [Docker / Kubernetes など]

【要件】
- セキュリティグループ・ファイアウォールの設定
- 環境変数・シークレット管理
- ログ収集・監視設定
- バックアップ設定

環境別の差異を明確にし、IaCコード（Terraform/Ansible）として出力してください。
```

---

## 環境別設定方針

### 開発環境（Development）

```yaml
特徴:
  - デバッグモード有効
  - ホットリロード対応
  - テスト用データ自動投入
  - HTTPS不要（localhostのみ）
  - ログレベル: DEBUG

推奨ツール:
  - Docker Compose（ローカル）
  - devcontainer（VSCode）
```

### ステージング環境（Staging）

```yaml
特徴:
  - 本番同等の設定
  - テストデータ使用
  - HTTPS必須
  - ログレベル: INFO
  - 本番デプロイ前の最終確認環境

推奨ツール:
  - Terraform（インフラ）
  - Kubernetes（コンテナオーケストレーション）
```

### 本番環境（Production）

```yaml
特徴:
  - 高可用性構成（冗長化）
  - スケールアウト対応
  - 監視・アラート設定
  - ログレベル: WARN
  - バックアップ自動化

セキュリティ要件:
  - WAF設定
  - DDoS対策
  - 秘密情報はシークレットマネージャー管理
  - 最小権限の原則
```

---

## Docker Compose テンプレート（開発環境）

```yaml
# docker-compose.yml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres:password@db:5432/myapp
    volumes:
      - .:/app
      - /app/node_modules
    depends_on:
      - db
      - redis

  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_DB: myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

volumes:
  postgres_data:
```

---

## チェックリスト

### 構築前
- [ ] 要件・スペックが確定している
- [ ] セキュリティ要件が定義されている
- [ ] コスト試算が完了している

### 構築後
- [ ] 全サービスが起動している
- [ ] ヘルスチェックが通過している
- [ ] セキュリティスキャンが完了している
- [ ] 監視・アラートが設定されている
- [ ] ドキュメントが更新されている

---

## 関連ドキュメント

- [CI/CD構築](./01_CI_CD構築(CICDSetup).md)
- [デプロイ戦略](./05_デプロイ戦略(DeploymentStrategy).md)
- [セキュリティ診断](./02_セキュリティ診断(SecurityAudit).md)
