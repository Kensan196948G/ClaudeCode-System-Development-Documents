# 05 デプロイ戦略（Deployment Strategy）

---

## 概要

安全・迅速なデプロイを実現するための戦略設計と Claude Code による自動化プロンプトです。

---

## Claude Code 起動コマンド

```
以下のデプロイ戦略を設計・実装してください。

【対象サービス】
[サービス名・概要]

【デプロイ戦略】
[ ] Blue-Green デプロイ
[ ] Canary リリース
[ ] Rolling Update
[ ] Feature Flag

【要件】
- ダウンタイム: ゼロ（無停止）
- ロールバック: 5分以内
- 監視: デプロイ前後のメトリクス比較
- 通知: Slack/Teams への通知

GitHub Actions パイプラインとして実装してください。
```

---

## デプロイ戦略の比較

| 戦略 | ダウンタイム | リスク | ロールバック速度 | コスト |
|------|------------|--------|----------------|--------|
| Blue-Green | なし | 低 | 即時（DNS切替） | 高（2倍のリソース） |
| Canary | なし | 低 | 数分 | 中 |
| Rolling Update | なし | 中 | 数分〜数十分 | 低 |
| Recreate | あり | 高 | 数分 | 最低 |

---

## Blue-Green デプロイ

```
現在の構成:
  Load Balancer → [Blue 環境: 本番稼働中]
                  [Green 環境: 待機中]

デプロイ手順:
  1. Green 環境に新バージョンをデプロイ
  2. Green 環境でヘルスチェック・スモークテスト実行
  3. Load Balancer のルーティングを Green に切り替え
  4. Blue 環境を監視（問題あれば即ロールバック）
  5. 問題なければ Blue 環境を次回用として保持
```

### GitHub Actions 実装例

```yaml
name: Blue-Green Deploy
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to Green
        run: |
          # Green環境へデプロイ
          kubectl set image deployment/app-green app=$IMAGE_TAG

      - name: Health Check
        run: |
          kubectl rollout status deployment/app-green --timeout=5m

      - name: Switch Traffic
        run: |
          # Blue→Greenへトラフィック切替
          kubectl patch service app -p '{"spec":{"selector":{"slot":"green"}}}'

      - name: Notify
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
```

---

## Canary リリース

```
トラフィック配分:
  Phase 1: 本番 95% / Canary 5%
  Phase 2: 本番 80% / Canary 20%（問題なければ）
  Phase 3: 本番 50% / Canary 50%
  Phase 4: Canary 100%（完全移行）
```

### 判断基準（自動昇格条件）

```yaml
metrics:
  error_rate:
    threshold: 0.1%     # エラー率 0.1% 以下
  response_time_p99:
    threshold: 500ms    # P99 レイテンシ 500ms 以下
  availability:
    threshold: 99.9%    # 可用性 99.9% 以上
observation_window: 10m # 10分間の観測後に自動昇格
```

---

## ロールバック手順

```bash
# 即時ロールバック（Blue-Green）
kubectl patch service app -p '{"spec":{"selector":{"slot":"blue"}}}'

# Kubernetes ローリングロールバック
kubectl rollout undo deployment/app

# 特定バージョンへのロールバック
kubectl rollout undo deployment/app --to-revision=3
```

---

## 関連ドキュメント

- [CI/CD構築](./01_CI_CD構築(CICDSetup).md)
- [環境構築](./04_環境構築(EnvironmentSetup).md)
- [インシデント対応](../06_保守・移行(MaintenanceMigration)/03_インシデント対応(IncidentResponse).md)
