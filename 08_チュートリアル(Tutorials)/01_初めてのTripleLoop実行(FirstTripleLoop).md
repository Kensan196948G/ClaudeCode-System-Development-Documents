# 01 初めてのTriple Loop実行（First Triple Loop）

---

## このチュートリアルの目的

**所要時間**: 約30分（セットアップ） + 15時間（自律ループ実行）  
**難易度**: ⭐☆☆☆☆ 初級  
**前提**: Claude Code CLI がインストール済みであること

このチュートリアルでは、既存のGitHubリポジトリに対してTriple Loop 15Hを初めて起動するまでの手順を説明します。

---

## ステップ 1: プロジェクトの準備

### 1-1. リポジトリのクローン

```bash
git clone https://github.com/あなたのユーザー名/あなたのリポジトリ.git
cd あなたのリポジトリ
```

### 1-2. Claude Code の起動確認

```bash
claude --version
# 出力例: claude 1.2.3 (claude-sonnet-4-5)
```

---

## ステップ 2: .claude/ ディレクトリのセットアップ

```bash
# .claude/ ディレクトリを作成
mkdir -p .claude/commands .claude/hooks .claude/mcp-configs

# テンプレートから settings.json をコピー
# （このリポジトリを参照）
cat > .claude/settings.json << 'EOF'
{
  "model": "claude-sonnet-4-5",
  "permissions": {
    "allow": ["Read", "Write", "Edit", "bash", "Glob", "Grep"],
    "deny": ["bash(sudo rm -rf*)"]
  },
  "autoApprove": {
    "enabled": true,
    "rules": [
      { "tool": "Read", "auto": true },
      { "tool": "bash", "pattern": "npm (test|lint|build).*", "auto": true },
      { "tool": "bash", "pattern": "git (add|commit|status|log).*", "auto": true }
    ]
  },
  "session": { "checkpointsEnabled": true }
}
EOF
```

---

## ステップ 3: CLAUDE.md の作成

```bash
cat > .claude/CLAUDE.md << 'EOF'
# [プロジェクト名] — Claude Code 設定

## 役割
あなたは [プロジェクト名] の自律型開発エージェントです。

## Triple Loop 動作指示

### Monitor Loop
1. git status と git log で状態確認
2. テスト失敗・Lintエラーを収集
3. 優先度付きタスクリストを作成

### Build Loop
1. 優先度最上位から実装開始
2. Conventional Commits でコミット
3. 実装後は必ずテスト実行

### Verify Loop
1. 全テスト通過確認
2. セキュリティ問題の確認
3. 品質基準を満たした場合のみ次へ進む

## コーディング規約
- 言語: [あなたの言語]
- テスト: [あなたのテストツール]
- コミット: feat/fix/docs/refactor/test/chore
EOF
```

---

## ステップ 4: Triple Loop の起動

```bash
# Claude Code を起動
claude
```

Claude Code のプロンプトが表示されたら入力します：

```
フル自律開発ループを開始してください。
設定: Triple Loop 15H（2サイクル、900分）
全操作を自動承認で続行してください。
TASKS.md でタスクを管理してください。
```

---

## ステップ 5: 実行中の監視

### ログの確認

別のターミナルを開いて監視できます：

```bash
# アクティビティログ（Hooksを設定している場合）
tail -f /tmp/claude-activity.log

# Git コミット履歴
watch -n 60 "git log --oneline -10"
```

### VS Code での監視（推奨）

1. VS Code で同じフォルダを開く
2. サイドバーの Claude Code パネルを確認
3. OUTPUT タブ → "Claude Code" を選択

---

## ステップ 6: チェックポイントの活用

問題が発生した場合：

```
# Claude Code 内で入力
/rewind

# または Esc キーを2回押す
```

チェックポイント一覧から復元ポイントを選択します。

---

## 期待される成果物

Triple Loop 15H の完了後、以下が生成されます：

- 📝 `TASKS.md` — タスク完了記録
- 🔀 Git コミット — 実装された変更の履歴
- 📊 テスト結果レポート（ある場合）
- 🔒 セキュリティレポート

---

## トラブルシューティング

| 症状 | 対処法 |
|------|--------|
| Claude が止まった | `Ctrl+C` で停止 → `/rewind` で復元 → 再起動 |
| テストが失敗し続ける | `/rewind` で変更前に戻す |
| API レート制限 | ループ間隔を延長する（settings.json 調整） |
| 意図しないファイル変更 | `/rewind` → 「コードのみ復元」を選択 |

---

## 次のチュートリアル

- [02_VS Code拡張機能の活用](./02_VSCode拡張機能活用(VSCodeTutorial).md)
- [03_Hooks設定の実践](./03_Hooks実践設定(HooksPractice).md)
- [04_MCP外部連携入門](./04_MCP連携入門(MCPIntro).md)
