# 01 Anthropic API 基礎ガイド

> **概要**: Anthropic API（Messages API）の基本的な使い方、認証、リクエスト構造、エラーハンドリングを解説します。

---

## Anthropic API の概要

```
Anthropic API
├── Messages API      ← テキスト・画像・ツール使用の主要API
├── Batch API         ← 大量処理用の非同期API（50%割引）
├── Files API         ← ファイルのアップロード・管理
├── Models API        ← 利用可能なモデル一覧取得
└── Token Count API   ← トークン数の事前計算
```

---

## 認証設定

```bash
# 環境変数での設定（推奨）
export ANTHROPIC_API_KEY=sk-ant-api03-...

# または .env ファイル
echo "ANTHROPIC_API_KEY=sk-ant-api03-..." >> .env
```

---

## 基本的なメッセージ送信

### Python

```python
import anthropic

client = anthropic.Anthropic()  # ANTHROPIC_API_KEY を自動読み込み

message = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    messages=[
        {"role": "user", "content": "Hello, Claude!"}
    ]
)

print(message.content[0].text)
```

### TypeScript

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic(); // ANTHROPIC_API_KEY を自動読み込み

const message = await client.messages.create({
  model: 'claude-sonnet-4-6',
  max_tokens: 1024,
  messages: [
    { role: 'user', content: 'Hello, Claude!' }
  ],
});

console.log(message.content[0].text);
```

---

## システムプロンプト

```python
message = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    system="あなたはシニアバックエンドエンジニアです。コードレビューの専門家として振る舞ってください。",
    messages=[
        {"role": "user", "content": "このコードをレビューしてください: ..."}
    ]
)
```

---

## マルチターン会話

```python
messages = []

# ターン1
messages.append({"role": "user", "content": "認証システムを設計したい"})
response1 = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=2048,
    messages=messages
)
messages.append({"role": "assistant", "content": response1.content[0].text})

# ターン2
messages.append({"role": "user", "content": "OAuth2 と JWT のどちらが良いですか？"})
response2 = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=2048,
    messages=messages
)
```

---

## ストリーミング

```python
# ストリーミングでリアルタイム出力
with client.messages.stream(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    messages=[{"role": "user", "content": "コードを生成してください"}]
) as stream:
    for text in stream.text_stream:
        print(text, end="", flush=True)
```

### TypeScript でのストリーミング

```typescript
const stream = await client.messages.stream({
  model: 'claude-sonnet-4-6',
  max_tokens: 1024,
  messages: [{ role: 'user', content: '...' }],
});

for await (const chunk of stream) {
  if (chunk.type === 'content_block_delta' && 
      chunk.delta.type === 'text_delta') {
    process.stdout.write(chunk.delta.text);
  }
}
```

---

## レスポンス構造

```python
response = client.messages.create(...)

# 基本情報
response.id          # メッセージID
response.model       # 使用モデル
response.stop_reason # "end_turn" | "max_tokens" | "stop_sequence" | "tool_use"
response.usage       # トークン使用量

# コンテンツ
response.content[0].type  # "text" | "tool_use"
response.content[0].text  # テキストの場合

# トークン使用量
response.usage.input_tokens   # 入力トークン数
response.usage.output_tokens  # 出力トークン数
response.usage.cache_creation_input_tokens  # キャッシュ作成トークン
response.usage.cache_read_input_tokens      # キャッシュ読み込みトークン
```

---

## エラーハンドリング

```python
import anthropic
from anthropic import (
    APIConnectionError,
    APIStatusError,
    APITimeoutError,
    RateLimitError,
    AuthenticationError,
)

try:
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=1024,
        messages=[{"role": "user", "content": "..."}]
    )
except RateLimitError as e:
    print(f"レート制限: {e.status_code} - {e.message}")
    # リトライロジック（指数バックオフ推奨）
except AuthenticationError as e:
    print(f"認証エラー: APIキーを確認してください")
except APIConnectionError as e:
    print(f"接続エラー: ネットワークを確認してください")
except APITimeoutError as e:
    print(f"タイムアウト: リクエストが時間切れになりました")
except APIStatusError as e:
    print(f"APIエラー: {e.status_code} - {e.message}")
```

---

## リトライ（自動リトライ設定）

```python
# 自動リトライの設定
client = anthropic.Anthropic(
    max_retries=3,        # 最大リトライ回数（デフォルト: 2）
    timeout=60.0,         # タイムアウト秒数
)

# または個別リクエストでの設定
with client.messages.with_options(max_retries=5).create(...):
    pass
```

---

## モデル一覧の取得

```python
# 利用可能なモデル一覧
models = client.models.list()
for model in models.data:
    print(f"{model.id}: {model.display_name}")
```

---

## トークン数の事前計算

```python
# リクエスト前にトークン数を確認（コスト管理に有用）
token_count = client.messages.count_tokens(
    model="claude-sonnet-4-6",
    messages=[{"role": "user", "content": "長いコード..."}]
)
print(f"推定入力トークン数: {token_count.input_tokens}")
```

---

## コスト計算（2025年時点）

| モデル | 入力 (1M tokens) | 出力 (1M tokens) |
|-------|----------------|----------------|
| Opus 4.7 | $15.00 | $75.00 |
| Sonnet 4.6 | $3.00 | $15.00 |
| Haiku 4.5 | $0.25 | $1.25 |

Prompt Caching でキャッシュヒット時は入力コストが **90% 削減**されます。

---

## SDK のインストール

```bash
# Python
pip install anthropic

# TypeScript/JavaScript
npm install @anthropic-ai/sdk

# 最新バージョン確認
pip install --upgrade anthropic
npm update @anthropic-ai/sdk
```

---

## 関連ドキュメント

- [ツール使用（Function Calling）](./03_ツール使用（FunctionCalling）(ToolUse).md)
- [Batch API 大量処理](./04_BatchAPI大量処理(BatchAPI).md)
- [Prompt Caching 最適化](./06_PromptCaching最適化(PromptCaching).md)
- [Claude Agent SDK](./02_ClaudeAgentSDK詳細(AgentSDK).md)
