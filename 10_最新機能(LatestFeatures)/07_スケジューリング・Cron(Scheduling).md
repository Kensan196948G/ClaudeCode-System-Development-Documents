# 07 スケジューリング・Cron ガイド

> **概要**: Claude Code の CronCreate・ScheduleWakeup・/loop・/schedule スキルを使った自動化・定期実行の完全ガイドです。

---

## スケジューリング機能の概要

Claude Code には3種類のスケジューリング機能があります：

```
┌─────────────────────────────────────────────────────────────────┐
│               スケジューリング機能の比較                           │
│                                                                  │
│  ScheduleWakeup  ─ 現在のループを N 秒後に再開（動的ペーシング）    │
│  /loop           ─ 繰り返しタスクを一定間隔で実行                   │
│  /schedule       ─ クラウドエージェントをcron スケジュールで実行    │
│  CronCreate      ─ サーバーサイドでの cron ジョブ登録              │
└─────────────────────────────────────────────────────────────────┘
```

---

## ScheduleWakeup（動的ループ制御）

現在の会話ループを指定秒後に再開します。長時間タスクの待機中に使用します。

### 使い方

```markdown
## ScheduleWakeup の活用例

ユーザー: 「CI が完了したら結果を教えてください」

AI の動作:
1. git push してCI を開始
2. ScheduleWakeup(delaySeconds=270, reason="CI完了確認待ち")
3. 270秒後に自動再開 → CI 結果を確認
```

### delaySeconds の選び方

| 待機内容 | 推奨 delaySeconds |
|---------|-----------------|
| ビルド完了待ち（通常） | 270（キャッシュ内） |
| テスト完了待ち（5分超） | 1200〜1800 |
| デプロイ完了待ち | 1800〜3600 |
| 定期ステータス確認 | 1200〜1800 |

```
重要: 300秒はプロンプトキャッシュTTLの境界
- 270秒以内: キャッシュ保持 → コスト効率◎
- 300秒超:   キャッシュ失効 → コスト増加
→ 「5分待つ」ときは 270s か 1200s+ のどちらかにする
```

---

## /loop コマンド（繰り返し実行）

タスクを一定間隔で繰り返し実行します。

```bash
# 30分ごとに Monitor を実行
/loop 30m ClaudeOS Monitor

# 2時間ごとに Development を実行
/loop 2h ClaudeOS Development

# 1時間15分ごとに Verify を実行
/loop 1h15m ClaudeOS Verify

# 間隔なしで自己ペース制御
/loop ClaudeOS Monitor
```

### ClaudeOS ループ設定例（CLAUDE.md より）

```markdown
# ClaudeOS ループ登録

起動後に以下を順番に実行：
/loop 30min   ClaudeOS Monitor
/loop 2h      ClaudeOS Development
/loop 1h15m   ClaudeOS Verify
/loop 1h15m   ClaudeOS Improvement
```

---

## /schedule コマンド（クラウドスケジュール）

クラウドエージェントを cron スケジュールで定期実行します。

```bash
# 毎朝9時にコードレビューを実行
/schedule "毎朝9時に未レビューPRを確認してコメントする" --cron "0 9 * * 1-5"

# 毎週月曜日に依存関係を更新
/schedule "毎週月曜日に npm outdated を確認してPRを作成" --cron "0 10 * * 1"

# 毎日午前2時にセキュリティスキャン
/schedule "毎日午前2時にセキュリティ脆弱性スキャン実行" --cron "0 2 * * *"
```

### スケジュール管理

```bash
# 登録済みスケジュール一覧
/schedule list

# スケジュール削除
/schedule delete [schedule-id]

# 手動トリガー（テスト実行）
/schedule run [schedule-id]
```

---

## CronCreate ツール

プログラムから cron ジョブを作成します：

```typescript
// CronCreate の使用例（Claude Code 内部）
CronCreate({
  schedule: "0 9 * * 1-5",  // 平日9時
  prompt: "未マージのPRをレビューして、ブロッカーがあれば報告する",
  timezone: "Asia/Tokyo"
})
```

### cron 式の参考

| 式 | 意味 |
|-----|------|
| `0 9 * * 1-5` | 平日の午前9時 |
| `0 */2 * * *` | 2時間ごと |
| `0 0 * * 0` | 毎週日曜の0時 |
| `*/15 * * * *` | 15分ごと |
| `0 2 1 * *` | 毎月1日の午前2時 |

---

## 自律開発での活用例

### ClaudeOS v8 スケジュール設定

```markdown
## 自律開発の時間管理

### 定期タスク（/schedule で登録）
- 毎朝8:30: GitHub Issues の優先順位付けと state.json 更新
- 毎日12:00: CI 状態確認と失敗 CI の修復
- 毎日17:00: 当日の進捗レポート生成と次日計画
- 毎週月曜9:00: 週次依存関係更新とセキュリティスキャン

### ループタスク（/loop で登録）
- 30分ごと: Monitor Loop（状態確認）
- 2時間ごと: Development Loop（実装）
- 1時間15分ごと: Verify Loop（検証）
```

---

## GitHub Actions との連携

```yaml
# .github/workflows/scheduled-review.yml
name: Scheduled AI Review

on:
  schedule:
    - cron: '0 9 * * 1-5'  # 平日9時
  workflow_dispatch:

jobs:
  ai-review:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Claude Code Review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          npx @anthropic-ai/claude-code \
            --non-interactive \
            --prompt "未レビューのPRを全て確認してレビューコメントを追加してください"
```

---

## スケジューリングの注意点

| 注意点 | 内容 |
|-------|------|
| **無限ループ禁止** | 終了条件を必ず設定する |
| **クールダウン** | 各ループ間に5〜15分の待機を設ける |
| **Token管理** | state.json でトークン使用量を追跡 |
| **5時間制限** | 最大実行時間を意識して計画 |
| **週次制限** | Opus 4.7 は週次利用制限あり（Max 20x） |

---

## 関連ドキュメント

- [Memory システム](./04_Memoryシステム(MemorySystem).md)
- [フル自律開発起動](../02_起動・設定(StartupConfig)/01_フル自律開発起動(FullAutoStart).md)
- [ループ監視プロンプト](../02_起動・設定(StartupConfig)/02_ループ監視プロンプト(LoopMonitorPrompt).md)
