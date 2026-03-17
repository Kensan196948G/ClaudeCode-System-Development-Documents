# 04 TripleLoop 起動スクリプト（Triple Loop Script）

---

## 概要

`triple-loop-15h.sh` は ClaudeCode の **Triple Loop アーキテクチャ** を  
最大15時間継続して自律実行するためのBashスクリプトです。

---

## スクリプト構成

```
triple-loop-15h.sh
├── 設定セクション（変数定義）
│   ├── MAX_DURATION    : 最大実行時間（デフォルト: 54000秒 = 15時間）
│   ├── SLEEP_INTERVAL  : ループ間隔（秒）
│   └── LOG_DIR         : ログ出力先
├── Monitor Loop 関数
├── Build Loop 関数
├── Verify Loop 関数
└── メインループ
```

---

## 使用方法

### 基本起動

```bash
# 実行権限付与
chmod +x triple-loop-15h.sh

# 起動（フォアグラウンド）
./triple-loop-15h.sh

# バックグラウンド起動（ログ記録付き）
nohup ./triple-loop-15h.sh > logs/triple-loop.log 2>&1 &
echo "PID: $!"
```

### 途中停止

```bash
# PID を確認して停止
ps aux | grep triple-loop
kill <PID>
```

---

## カスタマイズ

### 実行時間の変更

```bash
# スクリプト冒頭の変数を編集
MAX_DURATION=28800  # 8時間に変更
```

### プロンプトファイルの指定

スクリプト内で参照するプロンプトファイルを変更できます。

```bash
MONITOR_PROMPT=".loop-monitor-prompt.md"
VERIFY_PROMPT=".loop-verify-prompt.md"
```

---

## ループ動作フロー

```
起動
  │
  ▼
┌─────────────────────────────────┐
│  Monitor Loop                   │
│  - リポジトリ状態を監視          │
│  - エラー・課題を検出            │
│  - タスクを優先順位付け          │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│  Build Loop                     │
│  - コード実装                   │
│  - テスト実行                   │
│  - Gitコミット                  │
└──────────────┬──────────────────┘
               │
               ▼
┌─────────────────────────────────┐
│  Verify Loop                    │
│  - コード品質確認               │
│  - セキュリティチェック          │
│  - 合格/差し戻し判定            │
└──────────────┬──────────────────┘
               │
     ┌─────────┴──────────┐
     │ 15時間経過 or 完了  │
     └─────────┬──────────┘
               │ No → Monitor Loop へ戻る
               │ Yes → 終了
               ▼
             終了
```

---

## ログの確認

```bash
# リアルタイムログ監視
tail -f logs/triple-loop.log

# エラーのみ表示
grep -E "ERROR|WARN|FAIL" logs/triple-loop.log

# ループ回数確認
grep "Loop iteration" logs/triple-loop.log | wc -l
```

---

## 関連ファイル

| ファイル | 役割 |
|---------|------|
| `02_ループ監視プロンプト(LoopMonitorPrompt).md` | Monitor Loop のプロンプト定義 |
| `03_ループ検証プロンプト(LoopVerifyPrompt).md` | Verify Loop のプロンプト定義 |
| `01_フル自律開発起動(FullAutoStart).md` | システム全体の起動設定 |
