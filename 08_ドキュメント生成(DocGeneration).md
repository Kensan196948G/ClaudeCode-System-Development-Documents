# 08 ドキュメント生成（Doc Generation）

## Claude Code 起動コマンド

```bash
claude --dangerously-skip-permissions
```

## プロンプト指示

```
以下のコードベースのドキュメントを生成・整備してください。

【対象】
- ドキュメント対象: [FILE_PATH or MODULE or 全体]
- 生成するドキュメント種別:
  - [ ] README.md（プロジェクト概要・セットアップ・使い方）
  - [ ] API リファレンス（OpenAPI / JSDoc / TypeDoc）
  - [ ] アーキテクチャ図（Mermaid）
  - [ ] コードコメント（JSDoc / docstring）
  - [ ] CONTRIBUTING.md（コントリビューター向けガイド）
  - [ ] CHANGELOG.md（変更履歴）

【品質基準】
- README はセットアップ手順を実行するだけで動く状態にする
- API ドキュメントはパラメータ・レスポンス・エラーをすべて記載する
- Mermaid 図は実際のコードから自動生成する

【実行してほしいこと】
1. コードを解析してドキュメントに必要な情報を抽出する
2. 各ドキュメントを生成する
3. Mermaid でシーケンス図・クラス図・ER 図を生成する
4. docs/ ディレクトリに整理して配置する
5. README からすべてのドキュメントへリンクを張る
6. git commit（docs: ドキュメントを整備）する
```

## 使用場面

- OSS 公開前のドキュメント整備
- 新メンバーのオンボーディング資料作成
- API 仕様書の自動生成

## ポイント

- Mermaid 図を活用することで保守しやすいドキュメントになる
