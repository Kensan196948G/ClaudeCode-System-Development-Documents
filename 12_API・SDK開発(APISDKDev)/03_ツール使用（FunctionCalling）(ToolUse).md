# 03 ツール使用（Function Calling / Tool Use）ガイド

> **概要**: Claude に外部ツール・関数を呼び出させる「Tool Use」機能の完全ガイドです。

---

## Tool Use の仕組み

```
ユーザー: 「東京の天気を教えて」
    ↓
Claude: 「get_weather(city="Tokyo") を呼ぶべきだ」
    ↓
アプリ: get_weather 関数を実行 → "東京: 晴れ 25°C"
    ↓
Claude: 「東京は現在晴れで25°Cです」
```

Claude 自身はツールを実行しません。**呼び出すべきツールと引数を指示**し、アプリ側が実行して結果を返します。

---

## ツール定義の構造

```python
tool_definition = {
    "name": "tool_name",           # スネークケース推奨
    "description": "ツールの説明", # 詳細に書くほど精度向上
    "input_schema": {
        "type": "object",
        "properties": {
            "param1": {
                "type": "string",  # string, number, boolean, array, object
                "description": "パラメータの説明"
            },
            "param2": {
                "type": "number",
                "description": "数値パラメータ"
            }
        },
        "required": ["param1"]     # 必須パラメータ
    }
}
```

---

## 様々な型のツール定義

```python
tools = [
    # 文字列型
    {
        "name": "search_code",
        "description": "コードベースを検索する",
        "input_schema": {
            "type": "object",
            "properties": {
                "query": {
                    "type": "string",
                    "description": "検索クエリ"
                },
                "file_pattern": {
                    "type": "string",
                    "description": "対象ファイルパターン（例: *.ts）",
                    "default": "*"
                }
            },
            "required": ["query"]
        }
    },
    
    # 配列型
    {
        "name": "run_tests",
        "description": "指定したテストを実行する",
        "input_schema": {
            "type": "object",
            "properties": {
                "test_files": {
                    "type": "array",
                    "items": {"type": "string"},
                    "description": "テストファイルのパスリスト"
                },
                "verbose": {
                    "type": "boolean",
                    "description": "詳細出力を有効にする",
                    "default": false
                }
            },
            "required": ["test_files"]
        }
    },
    
    # 列挙型
    {
        "name": "set_log_level",
        "description": "ログレベルを設定する",
        "input_schema": {
            "type": "object",
            "properties": {
                "level": {
                    "type": "string",
                    "enum": ["debug", "info", "warning", "error"],
                    "description": "ログレベル"
                }
            },
            "required": ["level"]
        }
    }
]
```

---

## tool_choice の制御

```python
# 自動選択（デフォルト）
response = client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=1024,
    tools=tools,
    tool_choice={"type": "auto"},  # Claude が判断
    messages=[...]
)

# ツール使用を強制
response = client.messages.create(
    tool_choice={"type": "any"},  # 必ずいずれかのツールを呼ぶ
    ...
)

# 特定ツールの強制
response = client.messages.create(
    tool_choice={
        "type": "tool",
        "name": "search_code"  # 必ずこのツールを呼ぶ
    },
    ...
)

# ツール使用禁止
response = client.messages.create(
    tool_choice={"type": "none"},  # テキスト回答のみ
    ...
)
```

---

## 複数ツールの並列呼び出し

Claude は複数のツールを同時に呼び出すことがあります：

```python
def process_tool_calls(response):
    tool_results = []
    
    for block in response.content:
        if block.type != "tool_use":
            continue
        
        # ツールを識別して実行
        match block.name:
            case "read_file":
                result = read_file(block.input["path"])
            case "search_code":
                result = search_code(
                    block.input["query"],
                    block.input.get("file_pattern", "*")
                )
            case "run_tests":
                result = run_tests(
                    block.input["test_files"],
                    block.input.get("verbose", False)
                )
            case _:
                result = f"Unknown tool: {block.name}"
        
        tool_results.append({
            "type": "tool_result",
            "tool_use_id": block.id,
            "content": result
        })
    
    return tool_results
```

---

## エラーを伝達する tool_result

```python
# 成功の場合
tool_result = {
    "type": "tool_result",
    "tool_use_id": block.id,
    "content": "成功した結果"
}

# エラーの場合
tool_result = {
    "type": "tool_result",
    "tool_use_id": block.id,
    "content": "ファイルが見つかりませんでした: /path/to/file",
    "is_error": True  # エラーフラグ
}
```

---

## 実践的なコードレビューエージェント

```python
import subprocess

# コードレビュー用ツールセット
code_review_tools = [
    {
        "name": "read_file",
        "description": "ファイルを読み込む",
        "input_schema": {
            "type": "object",
            "properties": {
                "path": {"type": "string"}
            },
            "required": ["path"]
        }
    },
    {
        "name": "list_files",
        "description": "ディレクトリのファイル一覧を取得",
        "input_schema": {
            "type": "object",
            "properties": {
                "directory": {"type": "string"},
                "pattern": {"type": "string"}
            },
            "required": ["directory"]
        }
    },
    {
        "name": "run_lint",
        "description": "リントを実行して結果を返す",
        "input_schema": {
            "type": "object",
            "properties": {
                "files": {
                    "type": "array",
                    "items": {"type": "string"}
                }
            },
            "required": ["files"]
        }
    }
]

def execute_code_review_tool(name: str, input: dict) -> str:
    if name == "read_file":
        with open(input["path"]) as f:
            return f.read()
    elif name == "list_files":
        import glob
        pattern = input.get("pattern", "**/*")
        files = glob.glob(
            f"{input['directory']}/{pattern}",
            recursive=True
        )
        return "\n".join(files[:50])  # 最大50ファイル
    elif name == "run_lint":
        result = subprocess.run(
            ["eslint", "--format=json"] + input["files"],
            capture_output=True, text=True
        )
        return result.stdout[:5000]  # 最大5000文字
```

---

## JSON スキーマバリデーション

Claude の出力は必ず JSON スキーマに準拠しますが、念のため検証：

```python
from jsonschema import validate, ValidationError

def safe_tool_call(block):
    schema = get_tool_schema(block.name)
    try:
        validate(instance=block.input, schema=schema)
        return execute_tool(block.name, block.input)
    except ValidationError as e:
        return f"引数のバリデーションエラー: {e.message}"
```

---

## 関連ドキュメント

- [Claude Agent SDK 詳細](./02_ClaudeAgentSDK詳細(AgentSDK).md)
- [Anthropic API 基礎](./01_AnthropicAPI基礎(AnthropicAPIBasics).md)
- [Batch API 大量処理](./04_BatchAPI大量処理(BatchAPI).md)
