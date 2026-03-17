# 07 セキュリティ診断（Security Audit）

## Claude Code 起動コマンド

```bash
claude --dangerously-skip-permissions
```

## プロンプト指示

```
このプロジェクトのセキュリティ診断を実施し、脆弱性を修正してください。

【診断スコープ】
- 対象ディレクトリ: [PATH or 全体]
- 診断種別:
  - [ ] 依存関係の脆弱性（npm audit / pip-audit / govulncheck）
  - [ ] 静的解析（ESLint security plugin / Bandit / Semgrep）
  - [ ] 機密情報の検出（gitleaks / trufflehog）
  - [ ] OWASP Top 10 チェック
  - [ ] Docker イメージスキャン（trivy）

【実行してほしいこと（Security / Architect Agent が担当）】
1. 上記の診断ツールをすべて実行する
2. 検出結果を重大度別（Critical / High / Medium / Low）に整理する
3. Critical / High の脆弱性を即時修正する
4. Medium / Low は修正計画を提示する
5. 機密情報がコードに含まれている場合は即時除去し git の履歴からも削除する
6. .env.example に環境変数の定義を整備する
7. セキュリティ設定レポートを SECURITY.md に出力する

【修正後の確認】
- 再度診断ツールを実行して Critical / High が 0 件であることを確認する
- git commit（security: 脆弱性修正）する
```

## 使用場面

- リリース前のセキュリティチェック
- 定期的なセキュリティ保守
- 依存関係の脆弱性アラート対応

## ポイント

- gitleaks で機密情報が検出された場合、git history の書き換えはユーザー確認必須
