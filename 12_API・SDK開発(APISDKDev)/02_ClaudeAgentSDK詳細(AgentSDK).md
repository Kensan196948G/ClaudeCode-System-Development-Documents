# 02 Claude Agent SDK 詳細ガイド

> **概要**: Claude Agent SDK を使ってカスタムエージェントを構築する方法。ツール定義、エージェントループ、マルチエージェントシステムの実装方法を解説します。

---

## Claude Agent SDK とは

Claude Agent SDK は、Claude を核心とする自律エージェントを構築するためのフレームワークです。
ツール使用・エージェントループ・サブエージェント連携を簡単に実装できます。

```
Agent SDK の主な機能:
├── Tool Definition    ← 独自ツールの定義と登録
├── Agent Loop         ← 自律的な思考・行動サイクル
├── Sub-agents         ← エージェントのネスト・並列実行
├── State Management   ← エージェント状態の管理
└── Streaming          ← リアルタイム出力
```

---

## 基本的なエージェント構築

### シンプルなツール使用エージェント

```python
import anthropic
import json

client = anthropic.Anthropic()

# ツールの定義
tools = [
    {
        "name": "get_weather",
        "description": "指定した都市の現在の天気を取得します",
        "input_schema": {
            "type": "object",
            "properties": {
                "city": {
                    "type": "string",
                    "description": "都市名（例: Tokyo）"
                }
            },
            "required": ["city"]
        }
    }
]

# ツールの実装
def get_weather(city: str) -> str:
    # 実際の実装（気象APIを呼ぶ）
    return f"{city}の天気: 晴れ、25°C"

# エージェントループ
def run_agent(user_message: str):
    messages = [{"role": "user", "content": user_message}]
    
    while True:
        response = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=4096,
            tools=tools,
            messages=messages
        )
        
        # ツール呼び出しがない場合は終了
        if response.stop_reason == "end_turn":
            return response.content[0].text
        
        # ツール呼び出しを処理
        if response.stop_reason == "tool_use":
            # アシスタントの応答を追加
            messages.append({
                "role": "assistant",
                "content": response.content
            })
            
            # 各ツール呼び出しを実行
            tool_results = []
            for block in response.content:
                if block.type == "tool_use":
                    if block.name == "get_weather":
                        result = get_weather(**block.input)
                    else:
                        result = f"Unknown tool: {block.name}"
                    
                    tool_results.append({
                        "type": "tool_result",
                        "tool_use_id": block.id,
                        "content": result
                    })
            
            # ツール結果を追加
            messages.append({
                "role": "user",
                "content": tool_results
            })

result = run_agent("東京の天気を教えてください")
print(result)
```

---

## 複数ツールを持つエージェント

```python
import subprocess
import os

# ファイルシステム操作ツール
tools = [
    {
        "name": "read_file",
        "description": "ファイルの内容を読み込む",
        "input_schema": {
            "type": "object",
            "properties": {
                "path": {"type": "string", "description": "ファイルパス"}
            },
            "required": ["path"]
        }
    },
    {
        "name": "write_file",
        "description": "ファイルに内容を書き込む",
        "input_schema": {
            "type": "object",
            "properties": {
                "path": {"type": "string"},
                "content": {"type": "string"}
            },
            "required": ["path", "content"]
        }
    },
    {
        "name": "run_bash",
        "description": "Bashコマンドを実行する",
        "input_schema": {
            "type": "object",
            "properties": {
                "command": {"type": "string"}
            },
            "required": ["command"]
        }
    }
]

def execute_tool(tool_name: str, tool_input: dict) -> str:
    if tool_name == "read_file":
        with open(tool_input["path"]) as f:
            return f.read()
    elif tool_name == "write_file":
        with open(tool_input["path"], "w") as f:
            f.write(tool_input["content"])
        return "ファイルを書き込みました"
    elif tool_name == "run_bash":
        result = subprocess.run(
            tool_input["command"],
            shell=True,
            capture_output=True,
            text=True
        )
        return result.stdout + result.stderr
```

---

## マルチエージェントシステム

### オーケストレーター + サブエージェントパターン

```python
import anthropic
from concurrent.futures import ThreadPoolExecutor

client = anthropic.Anthropic()

def run_subagent(task: str, specialist_role: str) -> str:
    """専門エージェントを実行"""
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=4096,
        system=f"あなたは{specialist_role}の専門家です。",
        messages=[{"role": "user", "content": task}]
    )
    return response.content[0].text

def orchestrator(main_task: str) -> dict:
    """オーケストレーターが並列サブエージェントを管理"""
    
    # タスクを分解
    subtasks = {
        "architecture": f"{main_task} のアーキテクチャ設計",
        "security": f"{main_task} のセキュリティレビュー",
        "testing": f"{main_task} のテスト計画"
    }
    
    # 並列実行
    results = {}
    with ThreadPoolExecutor(max_workers=3) as executor:
        futures = {
            name: executor.submit(run_subagent, task, name)
            for name, task in subtasks.items()
        }
        for name, future in futures.items():
            results[name] = future.result()
    
    return results

results = orchestrator("ユーザー認証システムの実装")
```

---

## エージェントの状態管理

```python
from dataclasses import dataclass, field
from typing import List, Dict, Any

@dataclass
class AgentState:
    """エージェントの状態"""
    session_id: str
    messages: List[Dict] = field(default_factory=list)
    tool_calls: List[Dict] = field(default_factory=list)
    context: Dict[str, Any] = field(default_factory=dict)
    iteration: int = 0
    max_iterations: int = 10

class StatefulAgent:
    def __init__(self, system_prompt: str):
        self.client = anthropic.Anthropic()
        self.state = AgentState(session_id="agent-001")
        self.system_prompt = system_prompt
    
    def step(self, user_input: str) -> str:
        self.state.messages.append({
            "role": "user",
            "content": user_input
        })
        
        if self.state.iteration >= self.state.max_iterations:
            return "最大イテレーション数に達しました"
        
        self.state.iteration += 1
        
        response = self.client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=4096,
            system=self.system_prompt,
            messages=self.state.messages
        )
        
        reply = response.content[0].text
        self.state.messages.append({
            "role": "assistant",
            "content": reply
        })
        
        return reply
```

---

## ストリーミングエージェント

```python
async def streaming_agent(user_message: str):
    """リアルタイムストリーミングエージェント"""
    async with client.messages.stream(
        model="claude-sonnet-4-6",
        max_tokens=4096,
        tools=tools,
        messages=[{"role": "user", "content": user_message}]
    ) as stream:
        async for event in stream:
            if hasattr(event, 'delta'):
                if event.delta.type == 'text_delta':
                    yield event.delta.text
                elif event.delta.type == 'input_json_delta':
                    # ツール入力のストリーミング
                    pass
```

---

## Computer Use エージェント

GUI 操作を自動化する Computer Use 機能：

```python
# Computer Use ツールの定義
computer_tools = [
    {
        "type": "computer_20241022",
        "name": "computer",
        "display_width_px": 1920,
        "display_height_px": 1080
    },
    {
        "type": "bash_20241022",
        "name": "bash"
    },
    {
        "type": "text_editor_20241022",
        "name": "str_replace_editor"
    }
]

response = client.messages.create(
    model="claude-opus-4-7",  # Computer Use は Opus 推奨
    max_tokens=4096,
    tools=computer_tools,
    messages=[{
        "role": "user",
        "content": "ブラウザでGitHubを開き、新しいIssueを作成してください"
    }]
)
```

---

## TypeScript での Agent SDK

```typescript
import Anthropic from '@anthropic-ai/sdk';

const client = new Anthropic();

interface Tool {
  name: string;
  description: string;
  input_schema: object;
}

async function runAgent(
  userMessage: string,
  tools: Tool[],
  toolExecutor: (name: string, input: object) => Promise<string>
): Promise<string> {
  const messages: Anthropic.MessageParam[] = [
    { role: 'user', content: userMessage }
  ];

  while (true) {
    const response = await client.messages.create({
      model: 'claude-sonnet-4-6',
      max_tokens: 4096,
      tools,
      messages,
    });

    if (response.stop_reason === 'end_turn') {
      const textBlock = response.content.find(b => b.type === 'text');
      return textBlock?.text ?? '';
    }

    messages.push({ role: 'assistant', content: response.content });

    const toolResults = await Promise.all(
      response.content
        .filter(b => b.type === 'tool_use')
        .map(async (block) => {
          if (block.type !== 'tool_use') return null;
          const result = await toolExecutor(block.name, block.input);
          return {
            type: 'tool_result' as const,
            tool_use_id: block.id,
            content: result,
          };
        })
    );

    messages.push({ role: 'user', content: toolResults.filter(Boolean) });
  }
}
```

---

## 関連ドキュメント

- [ツール使用（Function Calling）](./03_ツール使用（FunctionCalling）(ToolUse).md)
- [Anthropic API 基礎](./01_AnthropicAPI基礎(AnthropicAPIBasics).md)
- [サブエージェント設計](../02_起動・設定(StartupConfig)/09_サブエージェント設計(SubagentDesign).md)
