# 01 新規プロジェクト初期化（New Project Init）

## Claude Code 起動コマンド

```bash
claude --dangerously-skip-permissions
```

## プロンプト指示

```
新規プロジェクトを初期化してください。以下の要件で進めてください。

【プロジェクト概要】
- プロジェクト名: [PROJECT_NAME]
- 技術スタック: [STACK] （例: Next.js + TypeScript + Prisma + PostgreSQL）
- 目的: [PURPOSE]

【実行してほしいこと】
1. ディレクトリ構造を設計・作成する
2. package.json / pyproject.toml など依存関係ファイルを初期化する
3. ESLint / Prettier / TypeScript などの開発ツールを設定する
4. .gitignore / .env.example を生成する
5. README.md にプロジェクト概要・セットアップ手順を記載する
6. git init & 初回コミットを行う
7. GitHub リポジトリ作成（gh repo create）してリモートを登録する

【品質基準】
- TypeScript strict モードを有効にする
- lint / format / typecheck がすべてパスする状態にする
- 環境変数はすべて .env.example に記載する

準備ができたら構成案を提示し、承認後に実装を開始してください。
```

## 使用場面

- 新規サービス・ツール・ライブラリの立ち上げ時
- ハッカソン・プロトタイプ開発の起点
- モノレポ構成の初期設定

## ポイント

- `[PROJECT_NAME]` `[STACK]` `[PURPOSE]` を実際の内容に置き換えて使用する
- 承認後に `--dangerously-skip-permissions` の全自動実行が走る
