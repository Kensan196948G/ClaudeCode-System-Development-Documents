# 05 Files API 管理ガイド

> **概要**: Anthropic Files API を使ってファイルをアップロード・再利用・管理する方法を解説します。大きなファイルを繰り返し送信するコストと時間を削減できます。

---

## Files API とは

Files API は、ファイルを Anthropic サーバーに一度アップロードし、**複数のリクエストで再利用**できる機能です。

```
通常の方法:
  リクエスト1: ファイル全体を送信 (10MB)
  リクエスト2: ファイル全体を再送信 (10MB)
  リクエスト3: ファイル全体を再送信 (10MB)
  → 30MB を毎回転送・課金

Files API を使う方法:
  アップロード: ファイルを一度送信 (10MB)
  リクエスト1: file_id のみ参照
  リクエスト2: file_id のみ参照
  リクエスト3: file_id のみ参照
  → コスト削減・高速化
```

---

## ファイルのアップロード

```python
import anthropic

client = anthropic.Anthropic()

# ファイルのアップロード
with open("large-codebase.pdf", "rb") as f:
    file_response = client.beta.files.upload(
        file=("large-codebase.pdf", f, "application/pdf")
    )

file_id = file_response.id
print(f"アップロード完了: {file_id}")
# 例: file_01ABCxyz...
```

---

## 対応ファイル形式

| フォーマット | MIME Type | 用途 |
|------------|-----------|------|
| PDF | `application/pdf` | 仕様書・マニュアル |
| PNG | `image/png` | スクリーンショット・図 |
| JPEG | `image/jpeg` | 写真・UI画面 |
| GIF | `image/gif` | アニメーション |
| WebP | `image/webp` | Web画像 |
| テキスト | `text/plain` | ログ・設定ファイル |

---

## アップロードしたファイルの使用

### テキスト/PDFファイルの参照

```python
# アップロード済みファイルを使ってメッセージ送信
response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=4096,
    messages=[
        {
            "role": "user",
            "content": [
                {
                    "type": "document",
                    "source": {
                        "type": "file",
                        "file_id": file_id  # アップロードしたファイルID
                    }
                },
                {
                    "type": "text",
                    "text": "この仕様書に基づいてAPIクライアントを実装してください"
                }
            ]
        }
    ]
)
```

### 画像ファイルの参照

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
                        "type": "file",
                        "file_id": image_file_id
                    }
                },
                {
                    "type": "text",
                    "text": "このUIデザインをReactコンポーネントとして実装してください"
                }
            ]
        }
    ]
)
```

---

## ファイルの管理

### ファイル一覧の取得

```python
# アップロード済みファイル一覧
files = client.beta.files.list()

for file in files.data:
    print(f"ID: {file.id}")
    print(f"  ファイル名: {file.filename}")
    print(f"  サイズ: {file.size / 1024:.1f} KB")
    print(f"  作成日: {file.created_at}")
```

### ファイルのメタデータ取得

```python
# 特定ファイルの情報を取得
file_info = client.beta.files.retrieve(file_id)
print(f"ファイル名: {file_info.filename}")
print(f"サイズ: {file_info.size}")
```

### ファイルの削除

```python
# ファイルを削除（ストレージ節約）
result = client.beta.files.delete(file_id)
print(f"削除完了: {result.deleted}")
```

---

## 実践的な活用例

### 例1: 大規模仕様書に基づくコード生成

```python
class SpecificationAgent:
    """仕様書を常駐させたコード生成エージェント"""
    
    def __init__(self, spec_pdf_path: str):
        self.client = anthropic.Anthropic()
        
        # 仕様書を一度アップロード
        with open(spec_pdf_path, "rb") as f:
            file_response = self.client.beta.files.upload(
                file=(spec_pdf_path, f, "application/pdf")
            )
        self.spec_file_id = file_response.id
        print(f"仕様書をアップロード: {self.spec_file_id}")
    
    def generate_code(self, component_name: str, language: str) -> str:
        """仕様書を参照してコードを生成"""
        response = self.client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=8192,
            messages=[{
                "role": "user",
                "content": [
                    {
                        "type": "document",
                        "source": {
                            "type": "file",
                            "file_id": self.spec_file_id  # 再利用
                        }
                    },
                    {
                        "type": "text",
                        "text": f"仕様書に基づいて{component_name}の{language}実装を作成してください"
                    }
                ]
            }]
        )
        return response.content[0].text
    
    def cleanup(self):
        """完了後にファイルを削除"""
        self.client.beta.files.delete(self.spec_file_id)
```

### 例2: 複数画像の一括分析

```python
import os

def analyze_ui_screenshots(screenshot_dir: str) -> list:
    """UIスクリーンショットを一括分析"""
    
    # スクリーンショットを全てアップロード
    file_ids = {}
    for filename in os.listdir(screenshot_dir):
        if filename.endswith(".png"):
            filepath = os.path.join(screenshot_dir, filename)
            with open(filepath, "rb") as f:
                response = client.beta.files.upload(
                    file=(filename, f, "image/png")
                )
            file_ids[filename] = response.id
    
    # 全スクリーンショットを一括分析
    results = []
    for filename, file_id in file_ids.items():
        response = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=1024,
            messages=[{
                "role": "user",
                "content": [
                    {"type": "image", "source": {"type": "file", "file_id": file_id}},
                    {"type": "text", "text": "このUIのアクセシビリティ問題を指摘してください"}
                ]
            }]
        )
        results.append({
            "file": filename,
            "analysis": response.content[0].text
        })
    
    # クリーンアップ
    for file_id in file_ids.values():
        client.beta.files.delete(file_id)
    
    return results
```

---

## Files API の制限・注意事項

| 項目 | 詳細 |
|------|------|
| 最大ファイルサイズ | 32 MB |
| 最大ストレージ容量 | アカウントの制限に準拠 |
| ファイルの保持期間 | 明示的に削除するまで保持 |
| beta フラグ | `betas=["files-api-2025-04-14"]` が必要（将来的に不要になる予定） |

---

## beta フラグの指定方法

```python
# beta フラグ付きでアップロード
file_response = client.beta.files.upload(
    file=("document.pdf", f, "application/pdf"),
    betas=["files-api-2025-04-14"]
)

# beta フラグ付きでメッセージ送信
response = client.beta.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=4096,
    messages=[...],
    betas=["files-api-2025-04-14"]
)
```

---

## 関連ドキュメント

- [Anthropic API 基礎](./01_AnthropicAPI基礎(AnthropicAPIBasics).md)
- [Batch API 大量処理](./04_BatchAPI大量処理(BatchAPI).md)
- [Prompt Caching 最適化](./06_PromptCaching最適化(PromptCaching).md)
- [Web Search・Vision](../10_最新機能(LatestFeatures)/06_WebSearch・Vision(WebSearchVision).md)
