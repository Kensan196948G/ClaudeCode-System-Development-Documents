# 04 Memory システム（Memory System）ガイド

> **概要**: Claude Code のセッション横断的な記憶機能。会話をまたいでユーザー情報・プロジェクト文脈・学習内容を永続化します。

---

## Memory システムとは

Memory システムは、会話が終了しても重要な情報を次のセッションに引き継ぐ**永続記憶機能**です。
ファイルベースで実装されており、`MEMORY.md`（インデックス）+ 個別 `.md` ファイルで構成されます。

```
┌─────────────────────────────────────────────────────────────────┐
│                    Memory システム構成                           │
│                                                                  │
│  ~/.claude/projects/[project-path]/memory/                       │
│       ├── MEMORY.md              ← インデックス（常時ロード）     │
│       ├── user_role.md           ← ユーザー情報記憶              │
│       ├── feedback_testing.md    ← フィードバック記憶            │
│       ├── project_context.md     ← プロジェクト文脈記憶          │
│       └── reference_links.md    ← 参照情報記憶                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## 記憶の4タイプ

### 1. user（ユーザー記憶）

ユーザーの役割・専門知識・好みを記録し、回答スタイルを最適化します。

```markdown
---
name: user-role-expertise
description: ユーザーはバックエンドエンジニア、Goに精通、React初心者
metadata:
  type: user
---

バックエンドエンジニア。Go歴10年。Reactはこのプロジェクトが初めて。
フロントエンドの説明はバックエンドの概念に例えて説明すること。
```

### 2. feedback（フィードバック記憶）

正しいアプローチと避けるべきアプローチを記録します。

```markdown
---
name: feedback-no-mock-db
description: テストでDBをモックしない。本物のDBを使う。
metadata:
  type: feedback
---

テストでは実際のDBに接続する。モックは昨年のインシデントで本番バグを見逃した原因。

**Why:** モック/本番の乖離でマイグレーション失敗を検知できなかった。
**How to apply:** テスト用DBをDockerで起動し、実接続でテストする。
```

### 3. project（プロジェクト記憶）

進行中の作業・期限・意思決定を記録します。

```markdown
---
name: project-merge-freeze
description: 2026-05-15 からマージフリーズ開始（モバイルリリースブランチカット）
metadata:
  type: project
---

2026-05-15 からマージフリーズ。モバイルチームのリリースブランチカットのため。
非クリティカルなPRは 2026-05-15 以降に持ち越し。

**Why:** モバイルv3.2のリリース準備
**How to apply:** このPRは 2026-05-14 までにマージできるか確認する。
```

### 4. reference（参照記憶）

外部システムの場所・目的を記録します。

```markdown
---
name: reference-linear-bugs
description: バグはLinearの "INGEST" プロジェクトで管理
metadata:
  type: reference
---

バグトラッキング: Linear プロジェクト "INGEST"
パイプラインのバグは必ずここで管理。
```

---

## MEMORY.md の構成

```markdown
# Memory Index

- [ユーザーロール・専門知識](user_role.md) — バックエンドエンジニア、Go熟練、React初心者
- [フィードバック：DBモック禁止](feedback_no_mock.md) — テストは実DBを使う
- [プロジェクト：マージフリーズ](project_merge_freeze.md) — 2026-05-15 から
- [参照：Linearプロジェクト](reference_linear.md) — バグトラッキング先
```

---

## Memory ファイルの書き方

### フロントマター形式

```markdown
---
name: [短いケバブケース識別子]
description: [1行サマリー ─ 次のセッションで関連性を判断するのに使用]
metadata:
  type: [user | feedback | project | reference]
---

[本文 ─ feedbackとprojectは以下を含める]
**Why:** [理由・根拠]
**How to apply:** [適用タイミング・条件]
```

### 記憶間のリンク

```markdown
[[feedback-no-mock-db]] を参照（関連記憶へのリンク）
```

---

## 記憶として保存すべき情報 vs しない情報

### 保存すべき

| 種類 | 例 |
|------|-----|
| ユーザーの専門性・役割 | 「Go熟練・React初心者」 |
| 繰り返す指摘・修正パターン | 「DBモック禁止の理由」 |
| 重要な設計決定とその理由 | 「JWTでなくOAuth2を選んだ理由」 |
| 期限・フリーズ日（絶対日付に変換） | 「2026-05-15 マージフリーズ」 |
| 外部システムの場所・用途 | 「Linear "INGEST" プロジェクト」 |

### 保存しない

| 種類 | 理由 |
|------|------|
| コードパターン・規約 | コードから推測可能 |
| Git 履歴・最近の変更 | `git log` が正確 |
| バグ修正のレシピ | コードと commit メッセージで確認 |
| 一時的なタスク詳細 | 現セッションのみ有効 |
| CLAUDE.md に書いてあること | 重複 |

---

## Memory の自動保存タイミング

AIは以下のタイミングで Memory を自動保存します：

```
ユーザーが明示的に「覚えて」と言う → 即座に保存
ユーザーが専門知識・役割を明かす → user 記憶を保存
ユーザーがアプローチを修正する → feedback 記憶を保存
ユーザーが意図しない使い方を褒める → feedback（成功）記憶を保存
期限・フリーズ・スコープ変更を述べる → project 記憶を保存
外部ツールの場所を教える → reference 記憶を保存
```

---

## Memory MCP との連携

Memory システムは Memory MCP サーバー（`mcp__plugin_claude-mem_mcp-search`）と連携します：

```bash
# Memory MCP で記憶を検索
search: "テストの方針"

# 最近のアクティビティを確認
timeline: last 7 days

# 特定の記憶を取得
get_observations: "feedback-no-mock-db"
```

---

## state.json との違い

| 機能 | Memory システム | state.json |
|------|----------------|-----------|
| 保存期間 | 永続（複数セッション） | セッション内短期 |
| 主な用途 | 長期記憶・学習 | 実行時間・フェーズ管理 |
| 更新頻度 | 低（有意義な情報のみ） | 高（フェーズ毎） |
| 対象 | ユーザー・プロジェクト知識 | 時間・トークン・状態 |

---

## 実践：Memory システムの設定例

```bash
# メモリディレクトリの作成（初回のみ）
mkdir -p ~/.claude/projects/$(pwd | sed 's/[\/\\]/-/g')/memory/

# MEMORY.md を初期化
cat > ~/.claude/projects/.../memory/MEMORY.md << EOF
# Memory Index
EOF
```

---

## 関連ドキュメント

- [CLAUDE.md 設定ガイド](../02_起動・設定(StartupConfig)/05_CLAUDE_MD設定ガイド(CLAUDEMDConfig).md)
- [MCP 設定ガイド](../02_起動・設定(StartupConfig)/08_MCP設定ガイド(MCPConfig).md)
- [スケジューリング・Cron](./07_スケジューリング・Cron(Scheduling).md)
