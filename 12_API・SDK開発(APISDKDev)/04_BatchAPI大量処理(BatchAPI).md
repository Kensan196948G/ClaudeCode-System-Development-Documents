# 04 Batch API 大量処理ガイド

> **概要**: Anthropic Batch API を使って大量のリクエストを非同期・低コストで処理する方法を解説します。通常のAPIより50%安価です。

---

## Batch API とは

Batch API は多数のリクエストを一括で非同期処理するAPIです。

```
┌─────────────────────────────────────────────────────────────────┐
│                    Batch API の特徴                              │
│                                                                  │
│  通常API: リクエスト → 即時応答（数秒）                            │
│  Batch API: 大量リクエスト → 非同期処理（最大24時間）              │
│                                                                  │
│  コスト: 通常比 50% OFF                                           │
│  適用: 大量コード分析・ドキュメント生成・バッチ翻訳 等              │
└─────────────────────────────────────────────────────────────────┘
```

---

## Batch API の制限

| 項目 | 制限 |
|------|------|
| 1バッチあたりの最大リクエスト数 | 10,000 |
| 1バッチあたりの最大トークン数 | 200,000,000 |
| 結果の保持期間 | 29日間 |
| 処理時間 | 最大24時間（通常1時間以内） |

---

## 基本的な使い方

### バッチリクエストの作成

```python
import anthropic

client = anthropic.Anthropic()

# バッチリクエストの定義
requests = [
    {
        "custom_id": "review-001",  # ユニークID（結果紐付け用）
        "params": {
            "model": "claude-haiku-4-5-20251001",  # 低コストモデル推奨
            "max_tokens": 1024,
            "messages": [
                {
                    "role": "user",
                    "content": "このコードをレビューしてください: def add(a, b): return a + b"
                }
            ]
        }
    },
    {
        "custom_id": "review-002",
        "params": {
            "model": "claude-haiku-4-5-20251001",
            "max_tokens": 1024,
            "messages": [
                {
                    "role": "user",
                    "content": "このコードをレビューしてください: class User: pass"
                }
            ]
        }
    }
]

# バッチ送信
batch = client.messages.batches.create(requests=requests)
print(f"バッチID: {batch.id}")
print(f"ステータス: {batch.processing_status}")
```

---

## バッチの状態確認

```python
# バッチの状態をポーリング
import time

def wait_for_batch(batch_id: str, interval: int = 60) -> object:
    """バッチ完了を待機する"""
    while True:
        batch = client.messages.batches.retrieve(batch_id)
        
        print(f"ステータス: {batch.processing_status}")
        print(f"完了: {batch.request_counts.succeeded}/{batch.request_counts.processing + batch.request_counts.succeeded}")
        
        if batch.processing_status == "ended":
            return batch
        
        time.sleep(interval)

batch = wait_for_batch(batch.id)
```

### ステータスの種類

| ステータス | 意味 |
|-----------|------|
| `in_progress` | 処理中 |
| `canceling` | キャンセル中 |
| `ended` | 処理完了（成功・失敗・キャンセルを含む） |

---

## 結果の取得

```python
# 結果をストリーミングで取得
results = {}

for result in client.messages.batches.results(batch.id):
    custom_id = result.custom_id
    
    if result.result.type == "succeeded":
        # 成功した場合
        message = result.result.message
        results[custom_id] = message.content[0].text
        print(f"✅ {custom_id}: {len(results[custom_id])} 文字")
        
    elif result.result.type == "errored":
        # エラーの場合
        error = result.result.error
        print(f"❌ {custom_id}: エラー - {error.type}: {error.message}")
        
    elif result.result.type == "canceled":
        print(f"⚠️ {custom_id}: キャンセルされました")
```

---

## 実践的な活用例

### 例1: 大量コードファイルのドキュメント生成

```python
import os
import glob

def batch_document_generation(src_dir: str) -> dict:
    """ソースコードから自動でドキュメントを生成"""
    
    # TypeScript ファイルを全て取得
    ts_files = glob.glob(f"{src_dir}/**/*.ts", recursive=True)
    
    # バッチリクエストを作成
    requests = []
    for i, filepath in enumerate(ts_files):
        with open(filepath) as f:
            code = f.read()
        
        requests.append({
            "custom_id": f"doc-{i:04d}",
            "params": {
                "model": "claude-haiku-4-5-20251001",
                "max_tokens": 2048,
                "messages": [{
                    "role": "user",
                    "content": f"以下のコードのドキュメントを日本語で生成してください:\n\n```typescript\n{code[:4000]}\n```"
                }]
            }
        })
    
    # バッチ送信
    batch = client.messages.batches.create(requests=requests)
    return batch.id
```

### 例2: バルクセキュリティ分析

```python
def batch_security_analysis(code_files: list) -> dict:
    """複数ファイルを一括でセキュリティ分析"""
    
    requests = []
    for file_path in code_files:
        with open(file_path) as f:
            code = f.read()
        
        requests.append({
            "custom_id": file_path,
            "params": {
                "model": "claude-sonnet-4-6",  # セキュリティは高精度モデルを使用
                "max_tokens": 2048,
                "messages": [{
                    "role": "user",
                    "content": f"このコードのセキュリティ脆弱性を分析してください:\n\n{code[:8000]}"
                }]
            }
        })
    
    batch = client.messages.batches.create(requests=requests)
    return batch.id
```

### 例3: 多言語翻訳バッチ

```python
LANGUAGES = ["English", "Chinese", "Korean", "Spanish"]

def batch_translate(documents: list, source_lang: str = "Japanese") -> str:
    """複数ドキュメントを複数言語に一括翻訳"""
    
    requests = []
    for doc_id, doc in enumerate(documents):
        for lang in LANGUAGES:
            requests.append({
                "custom_id": f"translate-{doc_id}-{lang.lower()}",
                "params": {
                    "model": "claude-haiku-4-5-20251001",
                    "max_tokens": len(doc) * 2,  # 翻訳後のトークン数を考慮
                    "messages": [{
                        "role": "user",
                        "content": f"以下の{source_lang}テキストを{lang}に翻訳してください:\n\n{doc}"
                    }]
                }
            })
    
    batch = client.messages.batches.create(requests=requests)
    return batch.id
```

---

## バッチのキャンセル

```python
# バッチをキャンセル（まだ処理されていないリクエストのみ）
canceled_batch = client.messages.batches.cancel(batch.id)
print(f"キャンセル状態: {canceled_batch.processing_status}")
```

---

## バッチ一覧の取得と管理

```python
# バッチ一覧の取得
batches = client.messages.batches.list(limit=10)

for batch in batches.data:
    print(f"ID: {batch.id}")
    print(f"  作成: {batch.created_at}")
    print(f"  状態: {batch.processing_status}")
    print(f"  成功: {batch.request_counts.succeeded}")
    print(f"  失敗: {batch.request_counts.errored}")
```

---

## コスト計算

```python
def estimate_batch_cost(num_requests: int, avg_input_tokens: int, avg_output_tokens: int, model: str = "haiku") -> float:
    """バッチAPIの概算コスト計算（USD）"""
    
    pricing = {
        "haiku": {"input": 0.25, "output": 1.25},    # per 1M tokens, 50% off
        "sonnet": {"input": 3.00, "output": 15.00},
        "opus": {"input": 15.00, "output": 75.00}
    }
    
    p = pricing[model]
    input_cost = (num_requests * avg_input_tokens / 1_000_000) * p["input"] * 0.5  # 50% off
    output_cost = (num_requests * avg_output_tokens / 1_000_000) * p["output"] * 0.5
    
    return input_cost + output_cost

cost = estimate_batch_cost(1000, 500, 200, "haiku")
print(f"推定コスト: ${cost:.4f} USD")
```

---

## 関連ドキュメント

- [Anthropic API 基礎](./01_AnthropicAPI基礎(AnthropicAPIBasics).md)
- [Files API 管理](./05_FilesAPI管理(FilesAPI).md)
- [Prompt Caching 最適化](./06_PromptCaching最適化(PromptCaching).md)
