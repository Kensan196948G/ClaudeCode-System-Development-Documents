# 02 VS Code 拡張機能の活用（VS Code Tutorial）

---

## このチュートリアルの目的

**所要時間**: 約20分  
**難易度**: ⭐⭐☆☆☆ 初〜中級  
**前提**: VS Code がインストール済み・Claude Code CLI が認証済み

VS Code の Claude Code 拡張機能を使ってインラインdiff・サイドバー・チェックポイントを活用する方法を説明します。

---

## ステップ 1: 拡張機能のインストール

```bash
code --install-extension anthropic.claude-code
```

インストール後、VS Code を再起動します。

---

## ステップ 2: サイドバーの確認

1. VS Code 左サイドバーに **Claude Code アイコン**（🤖）が表示されます
2. クリックしてパネルを開く
3. 以下のタブが利用可能です：
   - **Chat** — Claude との対話
   - **History** — 会話履歴・チェックポイント
   - **MCP** — 外部ツール接続状態

---

## ステップ 3: インラインdiffの体験

1. VS Code ターミナルで `claude` を起動
2. ファイルの変更を依頼：
   ```
   src/utils.ts の calculateTotal 関数を型安全にしてください
   ```
3. Claude がファイルを編集するとき、エディタに**インラインdiff**が表示されます：
   ```
   Before: function calculateTotal(items) {
   After:  function calculateTotal(items: Item[]): number {
   
   [✅ 承認] [❌ 拒否] [✏️ 編集]
   ```
4. 内容を確認して **✅ 承認** または **❌ 拒否** を選択

---

## ステップ 4: 選択コードをチャットに送る

1. エディタでコードを選択（例: 問題のある関数）
2. 右クリック → **"Claude Code に送る"**  
   （またはショートカット `Ctrl+Shift+C`）
3. サイドバーのチャットに選択コードが自動引用される
4. 具体的な質問を入力：
   ```
   このコードのパフォーマンス問題を教えてください
   ```

---

## ステップ 5: チェックポイントをHistoryから確認

1. サイドバー → **History** タブを開く
2. 現在のセッションのチェックポイント一覧が表示される
3. 特定のポイントをクリックして詳細を確認
4. **「ここに戻る」** ボタンでその時点に復元

---

## ステップ 6: Problems パネルとの連携

1. VS Code の **Problems** パネルを開く（`Ctrl+Shift+M`）
2. TypeScript エラーや Lint 警告が表示されている場合
3. チャットに入力：
   ```
   Problemsパネルのエラーをすべて修正してください
   ```
4. Claude が自動的に Problems を参照して修正します

---

## ショートカットまとめ

| ショートカット | 動作 |
|-------------|------|
| `Ctrl+Shift+C` | 選択コードをチャットに送る |
| `Ctrl+Shift+L` | Claude Code サイドバー開閉 |
| `Esc + Esc` | チェックポイントメニュー |
| `Ctrl+Enter` | チャット送信 |

---

## 次のチュートリアル

- [03_Hooks設定の実践](./03_Hooks実践設定(HooksPractice).md)
- [04_MCP外部連携入門](./04_MCP連携入門(MCPIntro).md)
