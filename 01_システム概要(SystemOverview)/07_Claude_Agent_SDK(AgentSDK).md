# 07 Claude Agent SDK（Agent SDK）

---

## 概要

**Claude Agent SDK**（旧称: Claude Code SDK）は、Claude Code の機能をプログラムから呼び出し、カスタムエージェント・自動化ワークフローを構築するための開発キットです。

---

## インストール

```bash
# npm（JavaScript/TypeScript）
npm install @anthropic-ai/claude-code-sdk

# pip（Python）
pip install anthropic-claude-code-sdk
```

---

## 基本的な使い方

### JavaScript/TypeScript

```typescript
import { ClaudeCode } from '@anthropic-ai/claude-code-sdk';

const agent = new ClaudeCode({
  apiKey: process.env.ANTHROPIC_API_KEY,
  model: 'claude-sonnet-4-5',
  workingDirectory: '/path/to/project'
});

// タスクを実行
const result = await agent.run({
  prompt: 'package.json を解析して依存関係の脆弱性を報告してください',
  allowedTools: ['Read', 'bash'],
  maxTurns: 10
});

console.log(result.output);
```

### Python

```python
from anthropic_claude_code_sdk import ClaudeCode

agent = ClaudeCode(
    api_key=os.environ["ANTHROPIC_API_KEY"],
    model="claude-sonnet-4-5",
    working_directory="/path/to/project"
)

result = agent.run(
    prompt="テストカバレッジを分析して改善提案をしてください",
    allowed_tools=["Read", "bash"],
    max_turns=10
)

print(result.output)
```

---

## 主要な設定オプション

```typescript
interface ClaudeCodeConfig {
  // 認証
  apiKey: string;

  // モデル選択
  model: 'claude-sonnet-4-5' | 'claude-opus-4-6' | 'claude-haiku-4-5';

  // 作業ディレクトリ
  workingDirectory: string;

  // ツール設定
  allowedTools?: string[];        // 許可するツール
  disallowedTools?: string[];     // 禁止するツール

  // 実行制限
  maxTurns?: number;              // 最大ターン数
  timeoutMs?: number;             // タイムアウト（ミリ秒）

  // CLAUDE.md 設定
  systemPromptOverride?: string;  // システムプロンプトの上書き
  appendSystemPrompt?: string;    // システムプロンプトへの追記

  // 環境変数の受け渡し
  env?: Record<string, string>;
}
```

---

## イベントとコールバック

SDK はエージェントの各ステップをイベントとして通知します：

```typescript
const agent = new ClaudeCode({ ... });

// ツール実行イベント
agent.on('toolUse', (event) => {
  console.log(`ツール実行: ${event.tool} - ${event.input}`);
});

// メッセージイベント
agent.on('message', (event) => {
  process.stdout.write(event.content);
});

// 完了イベント
agent.on('complete', (event) => {
  console.log(`完了: ${event.turns}ターン, ${event.tokens}トークン`);
});

// エラーイベント
agent.on('error', (event) => {
  console.error(`エラー: ${event.message}`);
});
```

---

## カスタムエージェントの構築

### シナリオ: PR コードレビューエージェント

```typescript
import { ClaudeCode } from '@anthropic-ai/claude-code-sdk';
import { execSync } from 'child_process';

async function reviewPullRequest(prNumber: number) {
  const diff = execSync(`gh pr diff ${prNumber}`).toString();
  
  const agent = new ClaudeCode({
    apiKey: process.env.ANTHROPIC_API_KEY,
    model: 'claude-sonnet-4-5',
    workingDirectory: process.cwd(),
    allowedTools: ['Read', 'bash'],
    maxTurns: 20
  });

  const result = await agent.run({
    prompt: `
以下のPR差分をレビューしてください:

${diff}

チェック項目:
1. セキュリティ脆弱性
2. パフォーマンス問題
3. コーディング規約違反
4. テスト不足

結果を GitHub PR コメント形式で出力してください。
    `
  });

  // 結果を PR コメントに投稿
  execSync(`gh pr comment ${prNumber} --body "${result.output}"`);
}
```

### シナリオ: 定期メンテナンスエージェント

```typescript
import { ClaudeCode } from '@anthropic-ai/claude-code-sdk';

async function weeklyMaintenance(repoPath: string) {
  const agent = new ClaudeCode({
    apiKey: process.env.ANTHROPIC_API_KEY,
    model: 'claude-opus-4-6',
    workingDirectory: repoPath,
    allowedTools: ['Read', 'Write', 'bash'],
    maxTurns: 50
  });

  const tasks = [
    '依存関係を最新版に更新してください（package.json）',
    'セキュリティ監査を実行して高/中リスクを修正してください',
    'テストを実行して失敗しているものを修正してください'
  ];

  for (const task of tasks) {
    console.log(`タスク実行: ${task}`);
    const result = await agent.run({ prompt: task });
    console.log(`完了: ${result.output.substring(0, 100)}...`);
  }
}
```

---

## Triple Loop との統合

Agent SDK を使って Triple Loop を外部からオーケストレーションする例：

```typescript
import { ClaudeCode } from '@anthropic-ai/claude-code-sdk';

async function tripleLoopOrchestrator(projectPath: string) {
  const config = {
    apiKey: process.env.ANTHROPIC_API_KEY,
    model: 'claude-sonnet-4-5',
    workingDirectory: projectPath,
    allowedTools: ['Read', 'Write', 'Edit', 'bash', 'Glob', 'Grep']
  };

  // Monitor Loop
  const monitor = new ClaudeCode(config);
  const monitorResult = await monitor.run({
    prompt: 'コードベースを解析して改善タスクリストを作成してください',
    maxTurns: 15
  });

  // Build Loop（並列実行）
  const tasks = parseTasks(monitorResult.output);
  const builders = tasks.map(task => {
    const builder = new ClaudeCode(config);
    return builder.run({ prompt: `次のタスクを実装してください: ${task}`, maxTurns: 30 });
  });
  
  const buildResults = await Promise.all(builders);

  // Verify Loop
  const verifier = new ClaudeCode(config);
  const verifyResult = await verifier.run({
    prompt: '実装されたすべての変更をテストして検証してください',
    maxTurns: 20
  });

  return { monitor: monitorResult, build: buildResults, verify: verifyResult };
}
```

---

## サブプロセスモード（非インタラクティブ）

CI/CD パイプラインから使用する場合：

```bash
# stdin からプロンプトを渡す
echo "テストを実行して結果を報告してください" | claude --no-interactive --output-format json

# 環境変数でモデル指定
CLAUDE_MODEL=claude-sonnet-4-5 claude --no-interactive \
  --prompt "package.json の依存関係を更新してください" \
  --allowed-tools Read,Write,bash
```

---

## 制限事項

| 項目 | 制限 |
|------|------|
| **最大コンテキスト** | 200K トークン |
| **最大ターン数** | デフォルト 50（`maxTurns` で変更可） |
| **タイムアウト** | デフォルト 30分（`timeoutMs` で変更可） |
| **並列実行** | API レート制限に依存 |
| **ファイルアクセス** | `workingDirectory` 配下のみ（デフォルト） |

---

## 関連ドキュメント

- [サブエージェント設計](../02_起動・設定(StartupConfig)/09_サブエージェント設計(SubagentDesign).md)
- [Hooks設定ガイド](../02_起動・設定(StartupConfig)/06_Hooks設定ガイド(HooksConfig).md)
- [MCP設定ガイド](../02_起動・設定(StartupConfig)/08_MCP設定ガイド(MCPConfig).md)
