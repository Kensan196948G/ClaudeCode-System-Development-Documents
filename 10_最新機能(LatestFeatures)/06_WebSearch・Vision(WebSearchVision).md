# 06 Web Search & Vision ガイド

> **概要**: Claude Code のリアルタイム Web 検索機能と画像理解（Vision）機能の活用ガイドです。

---

## Web Search 機能

### 概要

Claude Code は `WebSearch` / `WebFetch` ツールを通じて、**リアルタイムで Web から最新情報を取得**できます。
トレーニングデータのカットオフ以降の情報も取得可能です。

```
┌─────────────────────────────────────────────────────────────┐
│                  Web Search の動作フロー                     │
│                                                             │
│  質問 → WebSearch → 検索結果URL取得                          │
│                           ↓                                │
│              WebFetch → ページ全文取得                       │
│                           ↓                                │
│              Claude → 情報統合・回答生成                     │
└─────────────────────────────────────────────────────────────┘
```

---

## WebSearch の使い方

### 開発での活用シナリオ

#### シナリオ1: 最新ライブラリのドキュメント確認

```markdown
「React 19 の新しい Actions API の使い方を調べて、
現在の実装をアップグレードしてください。」
→ WebSearch で最新ドキュメントを取得してから実装
```

#### シナリオ2: セキュリティ脆弱性の調査

```markdown
「このプロジェクトで使っている express@4.18.2 に
最新のCVEがないか確認してください。」
→ CVE データベースをリアルタイム検索
```

#### シナリオ3: エラーメッセージの解決策検索

```markdown
「Cannot read properties of undefined (reading 'map')
というエラーの一般的な解決策を調べてください。」
```

#### シナリオ4: 技術比較

```markdown
「2025年現在の Redis vs Memcached の最新の比較を調べて、
このプロジェクトの要件に合った方を推奨してください。」
```

---

## WebFetch の使い方

特定のURLから情報を直接取得します：

```markdown
「https://docs.anthropic.com/claude/reference/messages-create
の最新の API 仕様を確認して、現在のコードが対応しているか確認してください。」
```

---

## Context7 MCP との連携

Context7 MCP サーバー（`mcp__plugin_context7_context7`）を使うと、
ライブラリの最新ドキュメントをより精度高く取得できます：

```markdown
## Context7 を使ったドキュメント取得

「/react を resolve して、
React 19 の useActionState フックの最新ドキュメントを取得してください。」
```

### Context7 対応ライブラリ例

| ライブラリ | Context7 ID |
|-----------|------------|
| React | /react |
| Next.js | /nextjs |
| TypeScript | /typescript |
| Prisma | /prisma |
| FastAPI | /fastapi |

---

## Vision（画像理解）機能

### 概要

Claude Code は画像ファイルを直接読み込んで分析できます。
スクリーンショット・ダイアグラム・UI モックアップを理解し、実装の参考にします。

### 対応画像フォーマット

| フォーマット | 用途 |
|------------|------|
| PNG | スクリーンショット・UI モック |
| JPEG | 実際の画面キャプチャ |
| GIF | アニメーション UI（静止フレーム解析） |
| WebP | Web 画像 |
| PDF | ドキュメント・仕様書 |

---

## Vision の活用シナリオ

### シナリオ1: UI モックアップからコード生成

```markdown
「添付のデザインモックアップを見て、
対応する React コンポーネントを実装してください。」

（スクリーンショットを共有）
→ Claude がデザインを解析してコンポーネントを生成
```

### シナリオ2: エラー画面の診断

```markdown
「このエラー画面のスクリーンショットを見て、
何が問題か診断してください。」

（エラー画面の画像を共有）
→ Claude がエラーを視覚的に解析
```

### シナリオ3: 既存UIの分析・改善

```markdown
「現在の UI のスクリーンショットです。
アクセシビリティと使いやすさの観点から改善点を指摘してください。」
```

### シナリオ4: アーキテクチャ図の読解

```markdown
「このシステム構成図を見て、
単一障害点（SPOF）を特定してください。」
```

### シナリオ5: PDF仕様書からの実装

```markdown
「この API 仕様書（PDF）を読んで、
TypeScript のクライアントライブラリを実装してください。」
```

---

## Anthropic API での画像処理

```python
import anthropic
import base64

client = anthropic.Anthropic()

# 画像ファイルを base64 エンコード
with open("screenshot.png", "rb") as f:
    image_data = base64.standard_b64encode(f.read()).decode("utf-8")

response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=2048,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": "image/png",
                        "data": image_data,
                    },
                },
                {
                    "type": "text",
                    "text": "このUI画面の問題点を指摘してください。"
                }
            ],
        }
    ],
)
```

### URL から直接画像を読み込む

```python
response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=2048,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "image",
                    "source": {
                        "type": "url",
                        "url": "https://example.com/architecture-diagram.png",
                    },
                },
                {
                    "type": "text",
                    "text": "このアーキテクチャ図の問題点を分析してください。"
                }
            ],
        }
    ],
)
```

---

## Web Search + Vision の組み合わせ

```markdown
「このエラー画面（添付画像）を見てください。
さらに、このエラーコードについて最新の解決策を Web で調べてください。
その上で、最適な修正方法を提案してください。」
```

---

## settings.json での Web 機能制御

```json
{
  "permissions": {
    "allow": [
      "WebSearch",
      "WebFetch"
    ],
    "deny": []
  },
  "webSearch": {
    "enabled": true,
    "maxResults": 5
  }
}
```

---

## 関連ドキュメント

- [MCP 設定ガイド](../02_起動・設定(StartupConfig)/08_MCP設定ガイド(MCPConfig).md)
- [Anthropic API 基礎](../12_API・SDK開発(APISDKDev)/01_AnthropicAPI基礎(AnthropicAPIBasics).md)
- [Claude 4.x モデルガイド](./01_Claude4xモデルガイド(Claude4xModels).md)
