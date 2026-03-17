# 06 VS Code 拡張機能（VS Code Extension）

---

## 概要

Claude Code の VS Code ネイティブ拡張機能（Beta）は、ターミナルベースの操作に加えて**グラフィカルな UI でコードとやり取り**できる統合開発環境を提供します。

---

## インストール

### 方法 1: VS Code Marketplace から

1. VS Code の Extensions パネルを開く（`Ctrl+Shift+X`）
2. `Claude Code` で検索
3. **"Claude Code" by Anthropic** をインストール
4. VS Code を再起動

### 方法 2: コマンドラインから

```bash
code --install-extension anthropic.claude-code
```

### 方法 3: Claude Code CLI 経由（推奨）

```bash
# Claude Code が自動でVS Code拡張を設定
claude setup vscode
```

---

## 主な機能

### 1. サイドバーパネル

VS Code のサイドバーに Claude Code パネルが追加されます：

```
サイドバー
├── 💬 Chat          ← Claude との対話
├── 📋 History       ← 会話履歴・チェックポイント一覧
├── 🔧 Tools         ← 使用中ツールの状態表示
└── 🔗 MCP           ← MCP接続状態
```

### 2. インライン差分表示（Inline Diff）

Claude がファイルを編集する際、**インライン差分ビュー**が表示されます：

```
Before:               After:
function add(a, b) {  function add(a: number, b: number): number {
  return a + b        return a + b;
}                     }

[✅ 承認] [❌ 拒否] [✏️ 修正]
```

ファイルを保存せずに変更内容を確認し、承認・拒否・修正を選択できます。

### 3. エディタ内コンテキスト参照

選択したコードを Claude に直接渡すことができます：

```
1. コードを選択
2. 右クリック → "Claude Code に送る"
3. または Ctrl+Shift+C（ショートカット）
4. チャットパネルに選択コードが自動引用される
```

### 4. 問題パネル連携

VS Code の Problems パネル（エラー・警告）を Claude が自動参照します：

```
[Problems]
  ❌ src/auth.ts(23): Type 'string' is not assignable to type 'number'
  ⚠️ src/utils.ts(45): Unused variable 'temp'
       ↓
  Claude が自動検出して修正提案
```

### 5. ターミナル統合

VS Code の統合ターミナルで Claude Code を起動すると、エディタと連携します：

```bash
# VS Code ターミナルで起動
claude

# エディタで開いているファイルを自動参照
> 今開いているファイルのエラーを修正して
```

---

## 設定

### 拡張機能の設定（settings.json）

```json
{
  "claude-code.autoApprove": false,
  "claude-code.showInlineDiff": true,
  "claude-code.sidebarPosition": "left",
  "claude-code.theme": "auto",
  "claude-code.shortcuts": {
    "sendToChat": "ctrl+shift+c",
    "openPanel": "ctrl+shift+l"
  }
}
```

### ワークスペース設定

VS Code のワークスペース設定ファイル（`.vscode/settings.json`）で Claude Code のデフォルト動作をプロジェクト単位で設定できます：

```json
// .vscode/settings.json
{
  "claude-code.projectContext": "This is a React + TypeScript project using Vite",
  "claude-code.autoReadFiles": ["README.md", "CLAUDE.md", "package.json"]
}
```

---

## ショートカット一覧

| ショートカット | 動作 |
|-------------|------|
| `Ctrl+Shift+C` | 選択コードをチャットに送る |
| `Ctrl+Shift+L` | Claude Code サイドバーを開く/閉じる |
| `Ctrl+Shift+R` | チェックポイントメニュー（/rewind） |
| `Ctrl+Enter` | チャット送信 |
| `Esc` | 現在の操作をキャンセル |

---

## Triple Loop との使い方

### 推奨ワークフロー

```
1. VS Code でプロジェクトを開く
2. サイドバーの Claude Code パネルを起動
3. チャットで Triple Loop を開始:
   「フル自律開発ループを開始してください（15H設定）」
4. ループ実行中:
   - インラインdiffで変更内容をリアルタイム確認
   - Problems パネルでエラー状況を監視
   - History でチェックポイントを確認
```

### ループ監視ダッシュボード

VS Code の OUTPUT パネルで Claude Code のログを確認：

```
Output タブ → "Claude Code" を選択
→ リアルタイムでループの進捗が表示
```

---

## トラブルシューティング

### 拡張機能が表示されない

```bash
# Claude Code CLI のバージョン確認（1.x.x 以上が必要）
claude --version

# 拡張機能を再インストール
code --uninstall-extension anthropic.claude-code
code --install-extension anthropic.claude-code
```

### API 認証エラー

```bash
# 認証状態確認
claude auth status

# 再認証
claude auth login
```

### インラインdiffが表示されない

VS Code の設定で確認：

```json
{
  "claude-code.showInlineDiff": true,
  "diffEditor.renderSideBySide": true
}
```

---

## 関連ドキュメント

- [クイックスタート](./04_クイックスタート(QuickStart).md)
- [チェックポイント機能](./05_チェックポイント機能(Checkpoints).md)
- [Hooks設定ガイド](../02_起動・設定(StartupConfig)/06_Hooks設定ガイド(HooksConfig).md)
- [MCP設定ガイド](../02_起動・設定(StartupConfig)/08_MCP設定ガイド(MCPConfig).md)
