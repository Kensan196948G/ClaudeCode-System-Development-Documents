# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## リポジトリの目的

ClaudeCode による自律型ソフトウェア開発システムの**ドキュメント集**。実行可能コードは含まない。
`templates/` ディレクトリのみが他プロジェクトへコピーして使うテンプレートファイル群。

---

## アーキテクチャの核心：Triple Loop

このドキュメント集が解説するシステムの中核は **Monitor → Build → Verify** の3ループ：

- **Monitor Loop**: リポジトリ状態の監視・タスク優先順位決定（15分ごと）
- **Build Loop**: コード実装・テスト実行・Gitコミット（タスク単位）
- **Verify Loop**: 品質ゲート確認・セキュリティ検査・合否判定（Build完了後）

7体エージェント（要件定義・アーキテクト・実装・テスト・セキュリティ・DevOps・ドキュメント）がこのループを並列実行する。

---

## ディレクトリ構成と役割

| フォルダ | 内容 |
|---------|------|
| `01_システム概要(SystemOverview)/` | アーキテクチャ・エージェント構成・クイックスタートの解説 |
| `02_起動・設定(StartupConfig)/` | CLAUDE.md・settings.json・Hooks・MCP の設定ガイド |
| `03_開発シナリオ(DevelopmentScenarios)/` | バグ修正・機能追加・リファクタリング等の再利用可能プロンプト集 |
| `04_インフラ・DevOps(InfraDevOps)/` | CI/CD・セキュリティ診断・コンテナ化のプロンプト集 |
| `05_技術実装(TechnicalImplementation)/` | API・フロントエンド・DB・認証・マイクロサービスの実装プロンプト |
| `06_保守・移行(MaintenanceMigration)/` | インシデント対応・依存関係更新・技術的負債管理 |
| `07_ドキュメント・ナレッジ(DocumentationKnowledge)/` | ドキュメント生成・コーディング規約・ADR管理 |
| `08_チュートリアル(Tutorials)/` | 手を動かして学ぶステップバイステップガイド |
| `09_事例集(UseCases)/` | 実プロジェクトへの適用事例と成功パターン |
| `templates/` | 新規プロジェクトにコピーする `.claude/` テンプレート一式 |
| `docs-en/` `docs-zh/` `docs-ko/` | 英語・中国語・韓国語の多言語版ドキュメント |

---

## ドキュメント追加・編集のルール

- **日本語ファイル名**: `NN_タイトル(EnglishName).md` 形式（例: `06_機能追加(FeatureAddition).md`）
- **フォルダ内 README**: 各フォルダを代表するインデックスは `README.md` ではなくルートの `README.md` で管理
- **多言語対応**: 重要な変更は `docs-en/`・`docs-zh/`・`docs-ko/` にも反映する
- **Conventional Commits**: コミットメッセージは `feat:` / `fix:` / `docs:` / `refactor:` を使用

---

## templates/ の使い方

```bash
# 新規プロジェクトに .claude/ ディレクトリをコピー
cp -r templates/.claude /path/to/your-project/

# CLAUDE.md 内の [PROJECT_NAME] を実際のプロジェクト名に置き換え
# settings.json のモデル・権限設定を調整
```

主要テンプレートファイル：
- `templates/.claude/CLAUDE.md` — Triple Loop 動作指示のベーステンプレート
- `templates/.claude/settings.json` — ツール制御・Hooks・自動承認の設定例
- `templates/.claude/commands/review.md` — `/review` カスタムコマンド定義
- `templates/.claude/commands/deploy.md` — `/deploy` カスタムコマンド定義

---

## 関連する設定コンセプト

**CLAUDE.md と settings.json の役割分担**（このドキュメント集の核心概念）:
- `CLAUDE.md` → AI への指示・役割・ルール（自然言語）
- `settings.json` → システム設定・ツール制御・Hooks（JSON）

**チェックポイント機能**: セッション内で `/rewind` または `Esc × 2` で変更を元に戻せる。
