# Claude Code プロジェクトテンプレート

このフォルダは、新しいプロジェクトに `.claude/` ディレクトリをセットアップするためのテンプレート集です。

## セットアップ方法

```bash
# プロジェクトルートへコピー
cp -r templates/.claude /path/to/your-project/.claude

# 設定を編集
nano /path/to/your-project/.claude/settings.json
nano /path/to/your-project/.claude/CLAUDE.md
```

## ファイル構成

```
.claude/
├── CLAUDE.md              ← AIへの指示（必須）
├── settings.json          ← システム設定（必須）
├── commands/
│   ├── review.md          ← /review カスタムコマンド
│   └── deploy.md          ← /deploy カスタムコマンド
├── hooks/
│   ├── post-write.sh      ← ファイル変更後のフック
│   └── pre-commit.sh      ← コミット前チェック
└── mcp-configs/
    ├── github.json        ← GitHub MCP設定
    └── slack.json         ← Slack MCP設定
```
