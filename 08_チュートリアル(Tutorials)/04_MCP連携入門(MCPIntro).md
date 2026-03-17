# 04 MCP 外部連携入門（MCP Intro）

---

## このチュートリアルの目的

**所要時間**: 約30分  
**難易度**: ⭐⭐⭐☆☆ 中級  
**前提**: GitHub アカウントとパーソナルアクセストークン（PAT）が必要

GitHub MCP を設定して、Claude Code から GitHub Issues を直接参照・操作できるようにします。

---

## ステップ 1: GitHub PAT の取得

1. https://github.com/settings/tokens にアクセス
2. **"Generate new token (classic)"** をクリック
3. スコープを選択:
   - `repo` — リポジトリ全操作
   - `read:org` — Organization 情報の読み取り
4. トークンを生成してコピー（一度しか表示されません）

---

## ステップ 2: 環境変数に設定

```bash
# ~/.bashrc または ~/.zshrc に追加
export GITHUB_TOKEN="ghp_あなたのトークン"

# 反映
source ~/.bashrc
```

---

## ステップ 3: GitHub MCP サーバーのインストール

```bash
npm install -g @anthropic-ai/mcp-server-github
```

---

## ステップ 4: MCP 設定ファイルの作成

```bash
cat > .claude/mcp-configs/github.json << 'EOF'
{
  "name": "github",
  "type": "stdio",
  "command": "mcp-server-github",
  "env": {
    "GITHUB_TOKEN": "${GITHUB_TOKEN}"
  },
  "capabilities": ["issues", "pull_requests", "repositories", "search"]
}
EOF
```

---

## ステップ 5: settings.json で MCP を有効化

```json
{
  "mcp": {
    "enabled": true,
    "servers": {
      "github": {
        "enabled": true,
        "configPath": ".claude/mcp-configs/github.json"
      }
    }
  }
}
```

---

## ステップ 6: 動作確認

Claude Code を再起動して試してみます：

```bash
claude
```

プロンプトに入力：

```
このリポジトリの未解決Issuesを一覧表示してください
```

GitHub の Issues が Claude Code に読み込まれて表示されます。

---

## 実用例: Issueからタスクを自動生成

```
未解決のIssue一覧を取得して、
優先度が高いものから順に今日のタスクリストを作成してください。
```

---

## 次のチュートリアル

- [05_サブエージェント並列実行](./05_サブエージェント並列実行(SubagentParallel).md)
