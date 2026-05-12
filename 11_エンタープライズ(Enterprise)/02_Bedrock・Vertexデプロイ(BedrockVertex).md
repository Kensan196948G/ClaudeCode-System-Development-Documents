# 02 AWS Bedrock・GCP Vertex デプロイガイド

> **概要**: 自社のクラウドインフラ（AWS Bedrock または GCP Vertex AI）で Claude を使用する設定方法です。データをAnthropicに送らず社内で処理できます。

---

## クラウドデプロイの選択肢

```
┌─────────────────────────────────────────────────────────────────┐
│               Claude デプロイオプション                           │
│                                                                  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐  │
│  │  Anthropic API   │  │   AWS Bedrock   │  │  GCP Vertex    │  │
│  │  (直接接続)      │  │  (AWS 経由)     │  │  (GCP 経由)    │  │
│  │                  │  │                 │  │                │  │
│  │ セットアップ簡単  │  │ AWS VPC 内処理  │  │ GCP VPC 内処理 │  │
│  │ 最新モデルすぐ   │  │ IAM 統合        │  │ IAM 統合       │  │
│  │ 使える           │  │ 既存 AWS 資産   │  │ 既存 GCP 資産  │  │
│  └─────────────────┘  └─────────────────┘  └────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## AWS Bedrock での設定

### 前提条件

1. AWS アカウントで Claude のモデルアクセスを有効化
2. Bedrock でのモデルID 取得
3. IAM ロールに `bedrock:InvokeModel` 権限付与

### 環境変数設定

```bash
# AWS 認証設定
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_DEFAULT_REGION=us-east-1

# または IAM ロール使用時（EC2/ECS/Lambda）
# 環境変数不要 - インスタンスロールが自動適用
```

### Claude Code での Bedrock 設定

```bash
# Bedrock を使用して Claude Code を起動
ANTHROPIC_MODEL=anthropic.claude-sonnet-4-6-20250514-v1:0 \
AWS_REGION=us-east-1 \
claude --bedrock
```

### settings.json での設定

```json
{
  "deployment": {
    "type": "bedrock",
    "region": "us-east-1",
    "modelId": "anthropic.claude-sonnet-4-6-20250514-v1:0"
  }
}
```

### Python SDK での Bedrock 使用

```python
import anthropic

# Bedrock クライアントの作成
client = anthropic.AnthropicBedrock(
    aws_region="us-east-1",
    # IAM ロール使用時は認証情報不要
    # aws_access_key="...",
    # aws_secret_key="..."
)

response = client.messages.create(
    model="anthropic.claude-sonnet-4-6-20250514-v1:0",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello!"}]
)
```

---

## AWS Bedrock モデルID 一覧

| Claude モデル | Bedrock モデルID |
|-------------|----------------|
| Claude Opus 4.7 | `anthropic.claude-opus-4-7-20251101-v1:0` |
| Claude Sonnet 4.6 | `anthropic.claude-sonnet-4-6-20250514-v1:0` |
| Claude Haiku 4.5 | `anthropic.claude-haiku-4-5-20251001-v1:0` |

---

## GCP Vertex AI での設定

### 前提条件

1. Google Cloud プロジェクトで Vertex AI API を有効化
2. Model Garden から Claude モデルへのアクセス許可
3. サービスアカウントに `aiplatform.endpoints.predict` 権限付与

### 環境変数設定

```bash
# GCP 認証設定
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
export GOOGLE_CLOUD_PROJECT=your-project-id
export GOOGLE_CLOUD_REGION=us-central1
```

### Claude Code での Vertex 設定

```bash
# Vertex を使用して Claude Code を起動
ANTHROPIC_MODEL=claude-sonnet-4-6@20250514 \
GOOGLE_CLOUD_PROJECT=your-project \
claude --vertex
```

### Python SDK での Vertex 使用

```python
import anthropic

# Vertex クライアントの作成
client = anthropic.AnthropicVertex(
    region="us-central1",
    project_id="your-project-id"
)

response = client.messages.create(
    model="claude-sonnet-4-6@20250514",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello!"}]
)
```

---

## GCP Vertex モデル名一覧

| Claude モデル | Vertex モデル名 |
|-------------|---------------|
| Claude Opus 4.7 | `claude-opus-4-7@20251101` |
| Claude Sonnet 4.6 | `claude-sonnet-4-6@20250514` |
| Claude Haiku 4.5 | `claude-haiku-4-5@20251001` |

---

## VPC 内でのプライベートデプロイ

### AWS VPC 設定例

```json
{
  "vpc": {
    "vpcId": "vpc-xxxxxxxxx",
    "subnetIds": ["subnet-xxxxxxxx"],
    "securityGroupIds": ["sg-xxxxxxxx"],
    "usePrivateEndpoint": true
  }
}
```

### アーキテクチャ例（AWS）

```
会社ネットワーク (VPC)
├── EC2 / ECS (Claude Code 実行環境)
│   ├── IAM ロール: bedrock:InvokeModel
│   └── VPC エンドポイント → AWS Bedrock
│
└── S3 (監査ログ保存)
    └── bucket: company-audit-logs
```

---

## Bedrock vs Vertex の選択基準

| 基準 | AWS Bedrock | GCP Vertex |
|------|-------------|-----------|
| 既存インフラ | AWS メイン | GCP メイン |
| データ保存先 | AWS S3/RDS | GCP Storage/BigQuery |
| AI/ML サービス | SageMaker と連携 | Gemini/AutoML と連携 |
| 規制対応 | AWS コンプライアンス | Google コンプライアンス |

---

## コスト比較

| デプロイ方法 | 入力1Mトークン | 出力1Mトークン | 追加コスト |
|------------|-------------|-------------|---------|
| Anthropic API (Sonnet 4.6) | $3.00 | $15.00 | なし |
| AWS Bedrock (Sonnet 4.6) | $3.00 + AWS料金 | $15.00 + AWS料金 | VPC/転送費 |
| GCP Vertex (Sonnet 4.6) | $3.00 + GCP料金 | $15.00 + GCP料金 | VPC/転送費 |

---

## 関連ドキュメント

- [エンタープライズセットアップ](./01_エンタープライズセットアップ(EnterpriseSetup).md)
- [ネットワーク分離・セキュリティ](./03_ネットワーク分離・セキュリティ(NetworkSecurity).md)
- [Anthropic API 基礎](../12_API・SDK開発(APISDKDev)/01_AnthropicAPI基礎(AnthropicAPIBasics).md)
