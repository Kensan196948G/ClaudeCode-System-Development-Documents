# 03 Git Worktree 並列開発ガイド

> **概要**: Git Worktree を使って複数のブランチを並列で開発・テストする Claude Code の高度な機能です。

---

## Git Worktree とは

Git Worktree は、1つのリポジトリから複数の作業ディレクトリを生成し、**同時に異なるブランチで作業**できる Git の機能です。Claude Code はこれを `EnterWorktree` / `ExitWorktree` ツールで自動管理します。

```
┌─────────────────────────────────────────────────────────────────┐
│                   Git Worktree 並列開発                          │
│                                                                  │
│  メインリポジトリ (main branch)                                   │
│       ├── worktree-A/ (feature/auth-oauth2)    ← Agent A        │
│       ├── worktree-B/ (bugfix/memory-leak)     ← Agent B        │
│       └── worktree-C/ (refactor/api-cleanup)   ← Agent C        │
│                                                                  │
│  3つのタスクが完全に独立して並列実行                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## Worktree の主な利点

| 利点 | 説明 |
|------|------|
| **並列開発** | 複数タスクを同時に進行させ開発速度を大幅向上 |
| **分離** | ブランチ間でファイル変更が干渉しない |
| **安全性** | メインブランチを汚染せずに実験できる |
| **自動クリーンアップ** | 変更なしの worktree は自動削除される |

---

## Claude Code での使い方

### EnterWorktree / ExitWorktree ツール

```markdown
## タスクを Worktree で実行する

「新しい worktree を作成して、feature/payment-integration ブランチで
決済機能を実装してください。メインブランチには影響を与えずに進めてください。」
```

### 自動 Worktree 管理

Claude Code の Agent ツールで `isolation: "worktree"` を指定すると：
- 新しい Git worktree が自動作成
- 変更がある場合 → ブランチ名とパスが返される
- 変更がない場合 → worktree は自動クリーンアップ

---

## 並列開発の実践パターン

### パターン1: 機能開発 + バグ修正の並列

```markdown
## SubAgent A（feature/user-profile）
- プロフィール編集機能の実装
- 対象ファイル: src/profile/*, tests/profile/*

## SubAgent B（bugfix/login-timeout）
- ログインタイムアウトバグの修正
- 対象ファイル: src/auth/session.ts

## 同時実行で作業時間を半減
```

### パターン2: マルチ環境テスト

```markdown
## Worktree A: Node.js 20 テスト
## Worktree B: Node.js 22 テスト
## 結果を比較して互換性確認
```

### パターン3: A/B テスト実装

```markdown
## Worktree A: 実装案A（Redux 状態管理）
## Worktree B: 実装案B（Zustand 状態管理）
## 両方をコードレビューして最良案を選択
```

---

## Worktree 操作コマンド

```bash
# Worktree 一覧表示
git worktree list

# 新しい Worktree 作成
git worktree add ../worktree-feature feature/new-feature

# 既存ブランチで Worktree 作成
git worktree add -b feature/my-feature ../worktree-my main

# Worktree 削除
git worktree remove ../worktree-feature

# 使われていない Worktree のクリーンアップ
git worktree prune
```

---

## CLAUDE.md での Worktree 設定

```markdown
# 並列開発ルール

## Worktree 使用条件
以下の場合は Worktree を使用する：
- 独立した2つ以上のタスクを同時進行
- リスクのある実験的変更
- 複数のブランチを比較・検証

## ブランチ命名規則
- feature/[機能名]: 新機能開発
- bugfix/[バグ名]: バグ修正
- refactor/[領域名]: リファクタリング
- experiment/[実験名]: 実験的変更

## Worktree パス規則
../worktree-[branch-type]-[short-name]
例: ../worktree-feature-payment
```

---

## SubAgent との組み合わせ

```markdown
## Agent Teams + Worktree の最強パターン

### スレッド A（Developer Agent）
- Worktree: feature/auth
- タスク: OAuth2 認証実装
- 担当ファイル: src/auth/

### スレッド B（Developer Agent）
- Worktree: feature/api
- タスク: REST API エンドポイント追加
- 担当ファイル: src/api/

### スレッド C（QA Agent）
- Worktree: test/integration
- タスク: 統合テスト作成
- 担当ファイル: tests/integration/

→ 3つが並列実行、完了後 main へマージ
```

---

## Worktree + CI/CD の連携

```yaml
# GitHub Actions: 並列 Worktree テスト
name: Parallel Worktree Tests

on: [pull_request]

jobs:
  test-unit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test -- --testPathPattern=unit

  test-integration:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test -- --testPathPattern=integration

  test-e2e:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm run test:e2e
```

---

## トラブルシューティング

| 問題 | 原因 | 解決策 |
|------|------|--------|
| Worktree がロックされている | プロセスが使用中 | `git worktree unlock <path>` |
| ブランチが既に存在する | 同名ブランチ作成 | `-b` フラグで別名を指定 |
| ディスク容量不足 | 多数の Worktree | `git worktree prune` で不要削除 |
| マージ競合 | 同じファイルを並列編集 | ファイル領域を事前に分担 |

---

## 関連ドキュメント

- [Plan Mode 計画モード](./02_PlanMode計画モード(PlanMode).md)
- [サブエージェント設計](../02_起動・設定(StartupConfig)/09_サブエージェント設計(SubagentDesign).md)
- [CI/CD 構築](../04_インフラ・DevOps(InfraDevOps)/01_CI_CD構築(CICDSetup).md)
