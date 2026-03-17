# 06 CI/CD 構築（CI/CD Setup）

## Claude Code 起動コマンド

```bash
claude --dangerously-skip-permissions
```

## プロンプト指示

```
このプロジェクトに CI/CD パイプラインを構築してください。

【環境情報】
- CI プラットフォーム: [GitHub Actions / GitLab CI / CircleCI など]
- デプロイ先: [Vercel / AWS / GCP / Heroku / VPS など]
- 技術スタック: [Node.js 20 / Python 3.12 / Go 1.22 など]

【パイプライン要件（Ops / QA Agent が設計）】
1. PR 作成時に実行
   - lint / format チェック
   - typecheck
   - ユニットテスト
   - セキュリティスキャン（npm audit / trivy）
2. main マージ時に実行
   - 上記すべて + 統合テスト
   - Docker イメージビルド
   - ステージング環境へ自動デプロイ
3. タグ push 時に実行（要ユーザー確認）
   - 本番環境へのデプロイ
   - リリースノート自動生成

【実行してほしいこと】
1. 現在のプロジェクト構成を分析する
2. 最適なパイプライン設計を提示して承認を得る
3. CI 設定ファイルを生成する（.github/workflows/*.yml など）
4. キャッシュ戦略を設定してビルド時間を最適化する
5. Secrets の設定手順を README に記載する
6. サンプル PR を作成して CI が正常に動くことを確認する

【完了基準】
- PR 作成で自動的に CI が実行される
- main へのマージでステージングが更新される
- CI 実行時間が 5 分以内（目安）
```

## 使用場面

- 新規プロジェクトへの CI 導入
- 既存 CI の高速化・信頼性向上
- デプロイフローの自動化

## ポイント

- Secrets の扱いのみユーザーが設定する（セキュリティ上 AI に委任しない）
