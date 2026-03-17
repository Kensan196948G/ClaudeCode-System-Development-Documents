# 05 バックアップ・復旧（Backup and Recovery）

---

## 概要

データ損失・システム障害からの迅速な復旧を実現するバックアップ戦略を  
Claude Code が設計・自動化するためのプロンプトです。

---

## Claude Code 起動コマンド

```
以下のシステムのバックアップ・復旧戦略を設計・実装してください。

【対象システム】
- データベース: [PostgreSQL 15 / MySQL 8 など]
- ファイルストレージ: [S3 / ローカルディスク など]
- 設定ファイル: [Kubernetes ConfigMap / 環境変数 など]

【RPO/RTO要件】
- RPO（目標復旧時点）: [1時間 / 24時間 など]
- RTO（目標復旧時間）: [30分 / 4時間 など]

【要件】
- 自動バックアップ（日次・週次・月次）
- バックアップの暗号化
- 別リージョン・別サービスへの複製
- 復旧テストの自動化

GitHub Actions ワークフローと復旧手順書を作成してください。
```

---

## バックアップ戦略（3-2-1 ルール）

```
3: データのコピーを3つ保持
2: 2種類の異なるメディア/ストレージに保存
1: 1つはオフサイト（別リージョン / クラウド）に保存

例:
  ① 本番DBのレプリカ（同リージョン）
  ② S3 バケット（同リージョン）
  ③ S3 バケット（別リージョン）← オフサイト
```

---

## バックアップスケジュール

| 種類 | 頻度 | 保持期間 | 用途 |
|------|------|---------|------|
| フルバックアップ | 週1回（日曜深夜） | 4週間 | 完全復旧 |
| 差分バックアップ | 日次（深夜） | 7日間 | 日次復旧 |
| トランザクションログ | 1時間ごと | 3日間 | ポイントインタイム復旧 |
| スナップショット | デプロイ前 | 3回分 | デプロイロールバック |

---

## PostgreSQL バックアップ自動化

```bash
#!/bin/bash
# scripts/backup-postgres.sh

BACKUP_DIR="/backups/postgres"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="${POSTGRES_DB}"
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${DATE}.sql.gz"

# バックアップ実行
pg_dump -h "$POSTGRES_HOST" -U "$POSTGRES_USER" "$DB_NAME" \
  | gzip > "$BACKUP_FILE"

# 暗号化
gpg --symmetric --cipher-algo AES256 \
  --passphrase "$BACKUP_PASSPHRASE" "$BACKUP_FILE"

# S3 にアップロード
aws s3 cp "${BACKUP_FILE}.gpg" \
  "s3://${BACKUP_BUCKET}/postgres/${DATE}/"

# 古いバックアップを削除（30日以上）
find "$BACKUP_DIR" -name "*.sql.gz*" -mtime +30 -delete

echo "バックアップ完了: ${BACKUP_FILE}.gpg"
```

---

## 復旧手順

### データベース復旧

```bash
# 1. バックアップファイルのダウンロード
aws s3 cp s3://${BACKUP_BUCKET}/postgres/YYYYMMDD_HHMMSS/mydb_YYYYMMDD_HHMMSS.sql.gz.gpg .

# 2. 復号
gpg --decrypt mydb_YYYYMMDD_HHMMSS.sql.gz.gpg > mydb.sql.gz

# 3. 解凍
gunzip mydb.sql.gz

# 4. リストア
psql -h $POSTGRES_HOST -U $POSTGRES_USER $DB_NAME < mydb.sql

# 5. 接続確認
psql -h $POSTGRES_HOST -U $POSTGRES_USER -c "SELECT COUNT(*) FROM users;" $DB_NAME
```

---

## 復旧テスト自動化

```yaml
# .github/workflows/recovery-test.yml
name: Backup Recovery Test
on:
  schedule:
    - cron: '0 3 * * 0'  # 毎週日曜 3:00

jobs:
  test-recovery:
    runs-on: ubuntu-latest
    steps:
      - name: Restore from latest backup
        run: ./scripts/restore-postgres.sh --test-mode
      - name: Verify data integrity
        run: ./scripts/verify-data-integrity.sh
      - name: Report result
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: '復旧テスト完了: ${{ job.status }}'
```

---

## 関連ドキュメント

- [インシデント対応](./03_インシデント対応(IncidentResponse).md)
- [環境構築](../04_インフラ・DevOps(InfraDevOps)/04_環境構築(EnvironmentSetup).md)
- [CI/CD構築](../04_インフラ・DevOps(InfraDevOps)/01_CI_CD構築(CICDSetup).md)
