# 01 Claude 4.x モデルガイド（Claude 4.x Model Guide）

> **対象バージョン**: Claude Opus 4.7 / Sonnet 4.6 / Haiku 4.5（2025年リリース）

---

## Claude 4.x モデルファミリー概要

Claude 4.x は Anthropic が 2025 年にリリースした第4世代モデルファミリーです。
各モデルはコスト・速度・知能のバランスが異なり、用途に応じて使い分けます。

```
┌─────────────────────────────────────────────────────────────────┐
│                    Claude 4.x モデルファミリー                     │
│                                                                  │
│  ┌─────────────────┐  ┌─────────────────┐  ┌────────────────┐  │
│  │  claude-opus-4-7 │  │claude-sonnet-4-6│  │claude-haiku-4-5│  │
│  │                  │  │                 │  │ -20251001      │  │
│  │  最高知能        │  │ バランス型      │  │ 高速・低コスト  │  │
│  │  複雑な推論      │  │ 汎用開発        │  │ 単純タスク     │  │
│  └─────────────────┘  └─────────────────┘  └────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 各モデルの詳細

### Claude Opus 4.7（`claude-opus-4-7`）

**位置付け**: 最高性能・最高コスト。複雑な推論・高難易度タスク向け。

| 項目 | 内容 |
|------|------|
| モデルID | `claude-opus-4-7` |
| 特徴 | 最高精度・深い推論・複雑な設計判断 |
| コンテキスト | 200K トークン |
| 最適用途 | アーキテクチャ設計、難解バグ分析、Plan Mode |
| Fast Mode | Opus 4.6 ベースで高速出力（/fast で切替） |

**推奨シナリオ**:
- システムアーキテクチャの設計・レビュー
- 複雑なリファクタリング計画の立案
- セキュリティ脆弱性の深い分析
- Plan Mode での詳細計画生成

### Claude Sonnet 4.6（`claude-sonnet-4-6`）

**位置付け**: バランス型・デフォルト推奨。日常的な開発タスク向け。

| 項目 | 内容 |
|------|------|
| モデルID | `claude-sonnet-4-6` |
| 特徴 | 速度と精度のバランス・コスト効率高 |
| コンテキスト | 200K トークン |
| 最適用途 | 機能実装、バグ修正、コードレビュー |
| Claude Code デフォルト | ✅ |

**推奨シナリオ**:
- 日常的なコーディングタスク全般
- Triple Loop の Build/Verify フェーズ
- テスト生成・ドキュメント作成
- CI/CD パイプラインでの自動実行

### Claude Haiku 4.5（`claude-haiku-4-5-20251001`）

**位置付け**: 最高速・最低コスト。単純・反復タスク向け。

| 項目 | 内容 |
|------|------|
| モデルID | `claude-haiku-4-5-20251001` |
| 特徴 | 超高速・低コスト・バッチ処理に最適 |
| コンテキスト | 200K トークン |
| 最適用途 | 監視タスク、ログ分析、単純変換 |

**推奨シナリオ**:
- Monitor Loop での定期ステータスチェック
- 大量ファイルの一括処理
- 単純なコードフォーマット・変換
- Batch API での並列処理

---

## settings.json でのモデル設定

```json
{
  "model": "claude-sonnet-4-6",
  "env": {
    "ANTHROPIC_MODEL": "claude-sonnet-4-6"
  }
}
```

### フェーズ別モデル使い分け（ClaudeOS v8 推奨）

```json
{
  "phases": {
    "plan": "claude-opus-4-7",
    "build": "claude-sonnet-4-6",
    "verify": "claude-sonnet-4-6",
    "monitor": "claude-haiku-4-5-20251001"
  }
}
```

---

## Fast Mode（高速モード）

`/fast` コマンドで Fast Mode を切り替えます。

| 状態 | モデル | 特徴 |
|------|--------|------|
| 通常 | claude-sonnet-4-6 | 標準速度・標準品質 |
| Fast | claude-opus-4-6 | Opus の高速出力版 |

```bash
# Fast Mode を有効化
/fast

# Fast Mode を無効化（再度 /fast）
/fast
```

---

## モデル選択の判断基準

```
タスクの複雑さ
    ↓
複雑な推論・設計が必要？ → YES → claude-opus-4-7
    ↓ NO
高速処理・コスト削減が必要？ → YES → claude-haiku-4-5-20251001
    ↓ NO
→ claude-sonnet-4-6（デフォルト）
```

---

## Extended Thinking との組み合わせ

高難易度タスクでは Extended Thinking と Opus 4.7 の組み合わせが最強。

```json
{
  "model": "claude-opus-4-7",
  "thinking": {
    "type": "enabled",
    "budget_tokens": 10000
  }
}
```

詳細は [05_ExtendedThinking拡張思考](./05_ExtendedThinking拡張思考(ExtendedThinking).md) を参照。

---

## Anthropic API でのモデル指定

```python
import anthropic

client = anthropic.Anthropic()

# Opus 4.7 - 高難易度タスク
response = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=4096,
    messages=[{"role": "user", "content": "..."}]
)

# Sonnet 4.6 - 標準タスク
response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=4096,
    messages=[{"role": "user", "content": "..."}]
)

# Haiku 4.5 - 高速タスク
response = client.messages.create(
    model="claude-haiku-4-5-20251001",
    max_tokens=1024,
    messages=[{"role": "user", "content": "..."}]
)
```

---

## 関連ドキュメント

- [ExtendedThinking拡張思考](./05_ExtendedThinking拡張思考(ExtendedThinking).md)
- [Plan Mode計画モード](./02_PlanMode計画モード(PlanMode).md)
- [Anthropic API基礎](../12_API・SDK開発(APISDKDev)/01_AnthropicAPI基礎(AnthropicAPIBasics).md)
- [settings.json設定ガイド](../02_起動・設定(StartupConfig)/07_settings_json設定ガイド(SettingsJson).md)
