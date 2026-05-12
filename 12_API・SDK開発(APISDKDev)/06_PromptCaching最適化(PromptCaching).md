# 06 Prompt Caching（プロンプトキャッシング）最適化ガイド

> **概要**: Anthropic の Prompt Caching 機能でAPIコストを最大 90% 削減・レイテンシを 85% 短縮する設定方法を解説します。

---

## Prompt Caching とは

Prompt Caching は、繰り返し使用するプロンプト（システムプロンプト・大量コンテキスト）を Anthropic サーバーにキャッシュし、2回目以降の呼び出しで再利用する機能です。

```
キャッシュなし:
  リクエスト1: システム(2000トークン) + 質問(100トークン) = 2100トークン課金
  リクエスト2: システム(2000トークン) + 質問(200トークン) = 2200トークン課金

キャッシュあり:
  リクエスト1: システム(2000トークン: 書き込み) + 質問(100トークン) = 通常+25%
  リクエスト2: システム(キャッシュヒット: 90%OFF!) + 質問(200トークン) ← 激安
```

---

## コスト削減効果

| 状況 | 削減率 |
|------|--------|
| キャッシュ書き込み | 通常比+25%（初回のみ） |
| キャッシュヒット | 入力トークン **90% 削減** |
| レイテンシ | 最大 **85% 短縮** |

---

## cache_control の設定

`cache_control: {"type": "ephemeral"}` をコンテンツに追加するだけです。

### システムプロンプトのキャッシュ

```python
import anthropic

client = anthropic.Anthropic()

# 長いシステムプロンプトをキャッシュ
response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    system=[
        {
            "type": "text",
            "text": """
あなたはシニアソフトウェアエンジニアです。
以下のプロジェクト仕様を熟知しています：

[プロジェクト仕様書 - 5000トークン分の詳細情報]
...
""",
            "cache_control": {"type": "ephemeral"}  # ここをキャッシュ
        }
    ],
    messages=[
        {"role": "user", "content": "このコードのレビューをしてください"}
    ]
)

# 2回目以降はキャッシュが使われる（90%コスト削減）
```

### マルチターン会話でのキャッシュ

```python
# 会話履歴の途中までキャッシュ
messages = [
    {"role": "user", "content": "大量のコンテキスト..."},
    {"role": "assistant", "content": "前の回答..."},
    # ... 多数のターン ...
    {
        "role": "user",
        "content": [
            {
                "type": "text",
                "text": "これまでの会話",
                "cache_control": {"type": "ephemeral"}  # ここまでキャッシュ
            }
        ]
    }
]

response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    messages=messages + [
        {"role": "user", "content": "新しい質問"}  # キャッシュ外
    ]
)
```

---

## Prompt Caching の最小要件

| モデル | 最小キャッシュトークン数 |
|-------|---------------------|
| Claude Sonnet 4.6 | 1,024 トークン |
| Claude Haiku 4.5 | 2,048 トークン |
| Claude Opus 4.7 | 1,024 トークン |

キャッシュするコンテンツがこれより少ない場合は効果がありません。

---

## キャッシュの TTL（有効期間）

| キャッシュタイプ | TTL |
|--------------|-----|
| ephemeral | 5 分 |

5分以内に同じキャッシュブロックを使用すれば TTL がリセットされます。

```python
# ScheduleWakeup と組み合わせた最適化
# キャッシュ TTL が 5分 なので、270秒以内に再利用するとキャッシュが有効

ScheduleWakeup(
    delaySeconds=270,  # 5分以内でキャッシュ保持
    reason="キャッシュTTL内での再利用"
)
```

---

## キャッシュヒット率の確認

```python
response = client.messages.create(...)

# トークン使用量を確認
usage = response.usage
print(f"入力トークン: {usage.input_tokens}")
print(f"出力トークン: {usage.output_tokens}")
print(f"キャッシュ書き込みトークン: {usage.cache_creation_input_tokens}")
print(f"キャッシュ読み込みトークン: {usage.cache_read_input_tokens}")

# キャッシュヒット率の計算
cache_ratio = usage.cache_read_input_tokens / (
    usage.input_tokens + usage.cache_read_input_tokens
) if usage.input_tokens > 0 else 0
print(f"キャッシュヒット率: {cache_ratio:.1%}")
```

---

## 実践的なキャッシュ戦略

### 戦略1: コードベース分析エージェント

```python
class CodebaseAnalysisAgent:
    """コードベース全体をキャッシュして質問に答えるエージェント"""
    
    def __init__(self, project_root: str):
        self.client = anthropic.Anthropic()
        self.project_root = project_root
        self._load_codebase()
    
    def _load_codebase(self):
        """プロジェクトの全コードを読み込む"""
        import os, glob
        
        code_files = []
        for pattern in ["**/*.ts", "**/*.py", "**/*.go"]:
            files = glob.glob(
                os.path.join(self.project_root, pattern),
                recursive=True
            )
            for filepath in files[:20]:  # 最大20ファイル
                try:
                    with open(filepath) as f:
                        content = f.read()
                    code_files.append(f"// {filepath}\n{content}\n")
                except Exception:
                    pass
        
        self.codebase_text = "\n".join(code_files)
    
    def ask(self, question: str) -> str:
        """コードベース全体を参照して質問に答える"""
        response = self.client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=4096,
            system=[
                {
                    "type": "text",
                    "text": f"以下のコードベースを分析する専門家として回答してください:\n\n{self.codebase_text}",
                    "cache_control": {"type": "ephemeral"}  # コードベースをキャッシュ
                }
            ],
            messages=[
                {"role": "user", "content": question}
            ]
        )
        return response.content[0].text
```

### 戦略2: 仕様書駆動開発

```python
def load_spec_and_implement(spec_path: str, tasks: list) -> list:
    """仕様書をキャッシュして複数タスクを実装"""
    
    with open(spec_path) as f:
        spec_content = f.read()
    
    results = []
    for task in tasks:
        response = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=4096,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {
                            "type": "text",
                            "text": f"仕様書:\n{spec_content}",
                            "cache_control": {"type": "ephemeral"}  # 仕様書をキャッシュ
                        },
                        {
                            "type": "text",
                            "text": f"タスク: {task}"
                        }
                    ]
                }
            ]
        )
        results.append(response.content[0].text)
    
    return results
```

---

## Extended Thinking とのキャッシュ組み合わせ

```python
# Extended Thinking の thinking ブロックもキャッシュ可能
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=16000,
    thinking={"type": "enabled", "budget_tokens": 8000},
    system=[{
        "type": "text",
        "text": "詳細なシステム仕様...",
        "cache_control": {"type": "ephemeral"}
    }],
    messages=[{"role": "user", "content": "設計レビューをしてください"}]
)
```

---

## コスト計算例

```python
def calculate_caching_savings(
    num_requests: int,
    cached_tokens: int,
    model: str = "sonnet"
) -> dict:
    """Prompt Caching によるコスト削減を計算"""
    
    pricing = {
        "sonnet": 3.00,   # per 1M input tokens
        "opus": 15.00,
        "haiku": 0.25
    }
    
    base_price = pricing[model]
    
    # キャッシュなし
    cost_without = num_requests * cached_tokens / 1_000_000 * base_price
    
    # キャッシュあり（初回書き込み + 残りヒット）
    cache_write_cost = cached_tokens / 1_000_000 * base_price * 1.25  # +25%
    cache_hit_cost = (num_requests - 1) * cached_tokens / 1_000_000 * base_price * 0.10  # 90%OFF
    cost_with = cache_write_cost + cache_hit_cost
    
    savings = cost_without - cost_with
    savings_pct = savings / cost_without * 100
    
    return {
        "without_caching": cost_without,
        "with_caching": cost_with,
        "savings": savings,
        "savings_percent": savings_pct
    }

result = calculate_caching_savings(100, 10000)
print(f"コスト削減: {result['savings_percent']:.1f}%")
```

---

## 関連ドキュメント

- [Anthropic API 基礎](./01_AnthropicAPI基礎(AnthropicAPIBasics).md)
- [Extended Thinking 拡張思考](../10_最新機能(LatestFeatures)/05_ExtendedThinking拡張思考(ExtendedThinking).md)
- [Batch API 大量処理](./04_BatchAPI大量処理(BatchAPI).md)
- [Claude 4.x モデルガイド](../10_最新機能(LatestFeatures)/01_Claude4xモデルガイド(Claude4xModels).md)
