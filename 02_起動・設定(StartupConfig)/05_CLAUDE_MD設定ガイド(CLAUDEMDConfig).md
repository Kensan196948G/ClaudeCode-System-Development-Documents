# 05 CLAUDE.md 設定ガイド（CLAUDE.md Configuration Guide）

---

## 概要

`CLAUDE.md` は Claude Code が起動時に **自動で読み込む** 設定ファイルです。  
このファイルに Triple Loop システムのプロンプトと動作指示を記述することで、  
Claude Code が自律的に開発ループを実行します。

> **Claude Code 2.0 以降**: CLAUDE.md と `settings.json` の役割が明確に分かれています。
> - `CLAUDE.md` → **AI への指示・役割・ルール**（自然言語）
> - `settings.json` → **システム設定・ツール制御**（JSON）

---

## ファイル配置場所と優先順位

```
優先度 高 ←──────────────────────────────────────── 低

プロジェクト固有           ユーザーグローバル
.claude/CLAUDE.md          ~/.claude/CLAUDE.md
   ↑ プロジェクト内の     ↑ 全プロジェクト共通の
     CLAUDE.md が優先        デフォルト設定
```

```
~/.claude/
├── CLAUDE.md          ← 全プロジェクト共通（グローバル設定）
└── settings.json      ← グローバル動作設定

your-project/
├── .claude/
│   ├── CLAUDE.md      ← プロジェクト固有指示（グローバルより優先）
│   ├── settings.json  ← プロジェクト固有設定
│   ├── commands/      ← カスタム /slash コマンド
│   │   └── review.md
│   ├── hooks/         ← フックスクリプト（オプション）
│   └── mcp-configs/   ← MCP サーバー設定
└── ...
```

---

## CLAUDE.md と settings.json の役割分担

| 内容 | どちらに書くか |
|------|--------------|
| AI の役割定義・人格設定 | **CLAUDE.md** |
| Triple Loop の動作指示 | **CLAUDE.md** |
| コーディング規約・コミット規約 | **CLAUDE.md** |
| 品質基準・完了条件 | **CLAUDE.md** |
| ツールの許可/禁止 | **settings.json** |
| 自動承認ルール | **settings.json** |
| モデル選択 | **settings.json** |
| Hooks（ライフサイクルイベント） | **settings.json** |
| MCP 設定 | **settings.json** + mcp-configs/ |

---

## 基本構成テンプレート

```markdown
# Claude Code システム設定

## 役割定義
あなたは [プロジェクト名] の自律型開発エージェントです。

## Triple Loop 動作指示

### Monitor Loop
- リポジトリの現状を確認し、課題を検出してください
- エラーログ・テスト失敗・TODOコメントを収集してください
- タスクを重要度・緊急度で優先順位付けしてください

### Build Loop
- 優先度最上位のタスクから実装を開始してください
- コミットは Conventional Commits 規約に従ってください
- 実装後は必ずテストを実行してください

### Verify Loop
- 実装コードのレビューを行ってください
- セキュリティ上の問題がないか確認してください
- 品質基準を満たした場合のみ次のタスクへ進んでください

## コーディング規約
- 言語: [言語名]
- フレームワーク: [フレームワーク名]
- テストフレームワーク: [テストフレームワーク名]
- コードフォーマッター: [フォーマッター名]

## コミットメッセージ規約
- feat: 新機能
- fix: バグ修正
- docs: ドキュメント変更
- refactor: リファクタリング
- test: テスト追加・修正
- chore: ビルド・依存関係変更
```

---

## プロジェクト別設定例

### Node.js / TypeScript プロジェクト

```markdown
## コーディング規約
- 言語: TypeScript 5.x
- フレームワーク: Express.js
- テスト: Jest + Supertest
- Lint: ESLint + Prettier
- ビルド: tsc

## 品質基準
- テストカバレッジ: 80% 以上
- TypeScript strict モード: 有効
- ESLint エラー: 0件
```

### Python プロジェクト

```markdown
## コーディング規約
- 言語: Python 3.11+
- フレームワーク: FastAPI
- テスト: pytest + httpx
- Lint: ruff + black
- 型チェック: mypy

## 品質基準
- テストカバレッジ: 85% 以上
- mypy エラー: 0件
- ruff エラー: 0件
```

---

## 設定の反映確認

```bash
# Claude Code を起動してCLAUDE.mdが読み込まれているか確認
claude "現在の設定ファイルの内容を要約してください"
```

---

## トラブルシューティング

### CLAUDE.md が読み込まれない

1. ファイルパスを確認: `ls ~/.claude/CLAUDE.md`
2. 文字エンコードを確認: UTF-8 であること
3. Claude Code のバージョンを確認: 最新版を使用

### 設定が意図通りに機能しない

1. プロンプトを明確・具体的に記述する
2. 相互矛盾する指示がないか確認する
3. `00_フル自律開発起動(FullAutoStart).md` のテンプレートを参照する

---

## 関連ドキュメント

- [フル自律開発起動](./01_フル自律開発起動(FullAutoStart).md)
- [ループ監視プロンプト](./02_ループ監視プロンプト(LoopMonitorPrompt).md)
- [ループ検証プロンプト](./03_ループ検証プロンプト(LoopVerifyPrompt).md)
- [settings.json 設定ガイド](./07_settings_json設定ガイド(SettingsJson).md) — ツール制御・自動承認の詳細
- [Hooks設定ガイド](./06_Hooks設定ガイド(HooksConfig).md) — ライフサイクルイベントの設定
- [MCP設定ガイド](./08_MCP設定ガイド(MCPConfig).md) — 外部ツール連携の設定
