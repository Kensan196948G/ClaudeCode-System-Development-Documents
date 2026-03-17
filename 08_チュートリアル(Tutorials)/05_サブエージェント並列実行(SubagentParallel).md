# 05 サブエージェント並列実行（Subagent Parallel）

---

## このチュートリアルの目的

**所要時間**: 約20分（設定）  
**難易度**: ⭐⭐⭐⭐☆ 中〜上級  
**前提**: `.claude/settings.json` と `CLAUDE.md` が設定済み

バックエンドとフロントエンドの実装を並列サブエージェントで同時進行させる方法を説明します。

---

## サブエージェントが有効なシナリオ

| シナリオ | 効果 |
|---------|------|
| バックエンドAPI + フロントエンドUI の同時実装 | 開発時間が約半分に |
| テストコード + 実装コードの同時作成 | 品質を保ちながら高速化 |
| 複数マイクロサービスの並列更新 | 依存関係がない場合に有効 |

---

## ステップ 1: settings.json にサブエージェント設定を追加

```json
{
  "subagents": {
    "enabled": true,
    "maxParallel": 3,
    "defaultModel": "claude-sonnet-4-5"
  }
}
```

---

## ステップ 2: CLAUDE.md に並列実行の指示を追加

`.claude/CLAUDE.md` に以下を追加します：

```markdown
## サブエージェント活用ルール

大規模な機能実装では以下のパターンで並列実行してください：

### バックエンド + フロントエンド並列実装
- Backend Agent: `src/api/` 配下のAPIエンドポイント実装
- Frontend Agent: `src/components/` 配下のUIコンポーネント実装
- 両エージェントは自分の担当ディレクトリ以外は変更しないこと

### 完了後の統合
- 両エージェントが完了したら Integration Agent がE2Eテストを実施
- メインエージェントが変更内容をマージして最終確認
```

---

## ステップ 3: 並列実行を依頼する

Claude Code のプロンプトに入力：

```
ユーザー管理機能を実装してください。
以下の2つのサブエージェントで並列実行してください：

1. Backend Agent: 
   - src/api/users.ts にCRUD APIを実装
   - src/models/User.ts にユーザーモデルを定義

2. Frontend Agent:
   - src/components/UserList.tsx に一覧コンポーネントを実装
   - src/components/UserForm.tsx に作成/編集フォームを実装

両方完了後、E2Eテストを実行して統合を確認してください。
```

---

## 実行中のモニタリング

Hooks を設定している場合、サブエージェントのログを確認できます：

```bash
tail -f /tmp/claude-activity.log
```

---

## 注意事項

- 同一ファイルへの競合書き込みは避けること（ファイル空間を明確に分ける）
- サブエージェントは API トークンを並列に消費するため、コスト増加に注意
- 並列数は `maxParallel: 3` 以下を推奨（APIレート制限対策）
