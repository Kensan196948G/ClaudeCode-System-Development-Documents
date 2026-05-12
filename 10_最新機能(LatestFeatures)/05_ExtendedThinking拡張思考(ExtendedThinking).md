# 05 Extended Thinking（拡張思考）ガイド

> **概要**: Claude の内部思考プロセスを深化させる機能。複雑な問題、多段階推論、難解なデバッグに威力を発揮します。

---

## Extended Thinking とは

Extended Thinking は、Claude が回答を生成する前に**長い内部思考チェーン**を展開する機能です。
通常よりも深く考え、より正確・詳細な回答を返します。

```
通常モード:      質問 → [短い思考] → 回答
Extended Think: 質問 → [深い思考プロセス (数千トークン)] → 高品質回答
                           ↑
                    ユーザーには thinking ブロックとして表示可能
```

---

## Extended Thinking が有効な場面

| シナリオ | 効果 |
|---------|------|
| 複雑なアルゴリズム設計 | 複数の実装アプローチを比較検討 |
| 難解なバグの根本原因分析 | 多段階の原因追跡 |
| アーキテクチャ設計の意思決定 | トレードオフの深い考察 |
| 数学・論理パズル | ステップバイステップの証明 |
| セキュリティ脆弱性分析 | 攻撃ベクター全体の把握 |

---

## API での設定方法

### Python SDK

```python
import anthropic

client = anthropic.Anthropic()

response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=16000,
    thinking={
        "type": "enabled",
        "budget_tokens": 10000  # 思考に使うトークン上限
    },
    messages=[{
        "role": "user",
        "content": "この OAuth2 実装のセキュリティ上の問題点を全て特定し、優先順位をつけて説明してください。"
    }]
)

# thinking ブロックと回答ブロックが返される
for block in response.content:
    if block.type == "thinking":
        print(f"[思考プロセス]: {block.thinking}")
    elif block.type == "text":
        print(f"[回答]: {block.text}")
```

### TypeScript SDK

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic();

const response = await client.messages.create({
  model: 'claude-opus-4-7',
  max_tokens: 16000,
  thinking: {
    type: 'enabled',
    budget_tokens: 10000,
  },
  messages: [{
    role: 'user',
    content: 'このコードのパフォーマンスボトルネックを特定してください。',
  }],
});
```

---

## budget_tokens の設定指針

| タスクの複雑さ | 推奨 budget_tokens |
|-------------|-------------------|
| 軽度（単純な問題） | 1,000 〜 3,000 |
| 中程度（通常のデバッグ） | 3,000 〜 8,000 |
| 高度（複雑なアーキテクチャ） | 8,000 〜 15,000 |
| 超高度（セキュリティ全体分析） | 15,000 〜 32,000 |

```python
# max_tokens は budget_tokens より大きく設定する
# budget_tokens: 思考に使うトークン
# max_tokens: 思考 + 回答の合計トークン上限

response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=20000,          # 思考(10000) + 回答(10000)
    thinking={
        "type": "enabled",
        "budget_tokens": 10000  # 思考上限
    },
    ...
)
```

---

## Claude Code での Extended Thinking

Claude Code では自動的に Extended Thinking を活用する場面があります：

```markdown
## Extended Thinking が自動活用される場面

1. Plan Mode での複雑な計画立案
2. セキュリティレビュー（/security-review）
3. アーキテクチャ設計の相談
4. 難解なバグの根本原因分析
```

### 明示的に深い思考を要求する

```markdown
「このシステムのボトルネックについて、できるだけ深く考えて分析してください。
パフォーマンス問題の根本原因、影響範囲、および優先順位付きの改善案を出してください。」
```

---

## Streaming との組み合わせ

```python
import anthropic

client = anthropic.Anthropic()

with client.messages.stream(
    model="claude-opus-4-7",
    max_tokens=16000,
    thinking={"type": "enabled", "budget_tokens": 8000},
    messages=[{"role": "user", "content": "..."}]
) as stream:
    for event in stream:
        if hasattr(event, 'type'):
            if event.type == 'content_block_start':
                if event.content_block.type == 'thinking':
                    print("🤔 思考中...")
            elif event.type == 'content_block_delta':
                if event.delta.type == 'thinking_delta':
                    print(event.delta.thinking, end='', flush=True)
                elif event.delta.type == 'text_delta':
                    print(event.delta.text, end='', flush=True)
```

---

## Extended Thinking と Prompt Caching

Extended Thinking の thinking ブロックは Prompt Caching できます：

```python
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=16000,
    thinking={"type": "enabled", "budget_tokens": 10000},
    system=[{
        "type": "text",
        "text": "あなたはシニアセキュリティエンジニアです。",
        "cache_control": {"type": "ephemeral"}  # システムプロンプトをキャッシュ
    }],
    messages=[...]
)
```

---

## 注意事項

| 項目 | 内容 |
|------|------|
| **対応モデル** | claude-opus-4-7（推奨）、claude-sonnet-4-6 |
| **コスト** | 通常より高い（thinking トークンも課金対象） |
| **レイテンシ** | 思考時間分だけ遅くなる |
| **用途** | 高精度が必要な場面に限定使用を推奨 |

---

## Triple Loop での活用方針

```
Monitor Loop: Extended Thinking OFF（高速処理優先）
Build Loop:   Extended Thinking 任意（複雑タスク時のみ）
Verify Loop:  Extended Thinking ON（セキュリティ・品質レビュー）
Plan Mode:    Extended Thinking ON（設計判断に最高品質を投入）
```

---

## 関連ドキュメント

- [Claude 4.x モデルガイド](./01_Claude4xモデルガイド(Claude4xModels).md)
- [Prompt Caching 最適化](../12_API・SDK開発(APISDKDev)/06_PromptCaching最適化(PromptCaching).md)
- [Anthropic API 基礎](../12_API・SDK開発(APISDKDev)/01_AnthropicAPI基礎(AnthropicAPIBasics).md)
