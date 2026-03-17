# 02 React フロントエンドへの適用事例（React Frontend Case）

---

## プロジェクト概要

| 項目 | 内容 |
|------|------|
| **プロジェクト種別** | React + TypeScript SPA |
| **規模** | 約8,000行（コンポーネント45本・カスタムフック12本） |
| **実行期間** | 1日（Triple Loop × 2サイクル） |
| **使用モデル** | claude-sonnet-4-5（Build）・claude-opus-4-6（設計確認） |
| **達成タスク** | 8タスク |

---

## 実行前の課題

1. React 17 から React 18 への移行（Concurrent Mode対応）
2. any型が全体の34%を占めていた
3. テストカバレッジ 45%（目標 70%）
4. Storybook のストーリーが古いコンポーネントのまま

---

## 特徴的な設定: サブエージェントによる並列実装

大量のコンポーネント移行を並列サブエージェントで対応しました：

```markdown
# CLAUDE.md への追記内容

## React 18 移行戦略（サブエージェント利用）

以下のサブエージェント構成で並列移行を実行してください:

1. Migration Agent A（src/components/atoms/）
   - Atomic なコンポーネントの React 18 対応

2. Migration Agent B（src/components/molecules/）
   - Molecular コンポーネントの対応

3. Type Agent（全体）
   - any型の型推論・型付け

各 Agent の完了後、メインが結合テストを実施すること。
```

---

## 実行結果

### サイクル 1（15H）

| 指標 | 開始 | 終了 |
|------|------|------|
| any型の割合 | 34% | **8%** |
| テストカバレッジ | 45% | **62%** |
| React 18 対応済みコンポーネント | 0/45 | **32/45** |
| TypeScriptエラー | 156件 | **12件** |

### サイクル 2（15H）

| 指標 | 開始 | 終了 |
|------|------|------|
| any型の割合 | 8% | **2%** |
| テストカバレッジ | 62% | **78%** ✅ |
| React 18 対応済みコンポーネント | 32/45 | **45/45** ✅ |
| TypeScriptエラー | 12件 | **0件** ✅ |
| Storybook ストーリー更新 | 0件 | **45件** ✅ |

---

## 学んだベストプラクティス

### 大規模移行はサブエージェントに分割する

コンポーネント数が多い場合、1つのエージェントが順番にやるより、ディレクトリ単位でサブエージェントに分けると2〜3倍速くなります。

### モデルを使い分ける

- **設計・アーキテクチャ判断** → `claude-opus-4-6`
- **実装・コード変換** → `claude-sonnet-4-5`

```
# CLAUDE.md に記載した指示
設計判断が必要な場合は /model claude-opus-4-6 に切り替えてください。
実装作業は claude-sonnet-4-5 で進めてください。
```

### Storybook の自動更新

Hooksで Write 後に Storybook のビルド確認を追加しました：

```json
{
  "PostToolUse": [{
    "matcher": { "tool_name": "Write", "tool_input": ".*\\.stories\\.tsx$" },
    "hooks": [{
      "type": "command",
      "command": "npx storybook build --quiet 2>&1 | tail -5"
    }]
  }]
}
```

---

## 参考

- [サブエージェント設計](../02_起動・設定(StartupConfig)/09_サブエージェント設計(SubagentDesign).md)
- [Hooks設定ガイド](../02_起動・設定(StartupConfig)/06_Hooks設定ガイド(HooksConfig).md)
