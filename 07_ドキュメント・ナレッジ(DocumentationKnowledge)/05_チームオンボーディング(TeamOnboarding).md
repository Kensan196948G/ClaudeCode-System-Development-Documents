# 05 チームオンボーディング（Team Onboarding）

---

## 概要

新メンバーが迅速にチームに参加・貢献できるよう、  
オンボーディング資料の作成と自動化を Claude Code が支援するためのプロンプトです。

---

## Claude Code 起動コマンド

```
以下のオンボーディング資料を作成・更新してください。

【対象ロール】
[ ] バックエンドエンジニア
[ ] フロントエンドエンジニア
[ ] インフラ・SREエンジニア
[ ] フルスタックエンジニア

【現在のプロジェクト情報】
[プロジェクト概要・技術スタック・リポジトリURL]

以下の観点でオンボーディングガイドを作成してください:
1. ローカル開発環境のセットアップ手順
2. コードベースの概要説明
3. 開発フロー・ワークフロー
4. よくある質問・トラブルシューティング
```

---

## オンボーディングチェックリスト

### 入社 Day 1

```markdown
## 環境セットアップ
- [ ] GitHubアカウントの登録・権限付与
- [ ] Slack / Teams チャンネルへの参加
- [ ] ローカル開発環境のセットアップ（README参照）
- [ ] VPN・認証ツールのセットアップ
- [ ] 必要なツールのインストール

## ツール確認
- [ ] Git の動作確認（git clone → git push）
- [ ] ローカルサーバーの起動確認
- [ ] テストの実行確認
```

### 入社 Week 1

```markdown
## コードベース理解
- [ ] システムアーキテクチャの概要説明（1時間）
- [ ] 主要コンポーネントのコードリーディング
- [ ] 既存PRの読み込み（最新5件）
- [ ] CI/CDパイプラインの動作確認

## 初めての貢献
- [ ] 簡単なバグ修正またはドキュメント改善に着手
- [ ] PRを作成してレビューを受ける
- [ ] CIを全通過させてマージ
```

### 入社 Month 1

```markdown
## 独立した貢献
- [ ] 中規模の機能を単独で実装
- [ ] コードレビューを他者に提供
- [ ] チームミーティングで発言・提案

## 目標設定
- [ ] 3ヶ月・6ヶ月の目標をマネージャーと設定
```

---

## ローカル開発環境セットアップスクリプト

```bash
#!/bin/bash
# scripts/setup-dev.sh
# 新メンバー向け開発環境自動セットアップ

set -e
echo "🚀 開発環境セットアップを開始します..."

# 必要ツールの確認
check_tool() {
  if ! command -v "$1" &> /dev/null; then
    echo "❌ $1 がインストールされていません"
    echo "   インストール方法: $2"
    exit 1
  fi
  echo "✅ $1 確認済み"
}

check_tool "git" "https://git-scm.com/"
check_tool "node" "https://nodejs.org/ (v20以上)"
check_tool "docker" "https://docs.docker.com/get-docker/"
check_tool "gh" "https://cli.github.com/"

# 依存関係インストール
echo "📦 依存関係をインストール中..."
npm ci

# 環境変数設定
echo "⚙️  環境変数を設定中..."
cp .env.example .env.local
echo "   .env.local を編集して必要な値を設定してください"

# Docker 起動
echo "🐳 Docker コンテナを起動中..."
docker compose up -d

# DBマイグレーション
echo "🗄️  データベースをセットアップ中..."
npm run db:migrate
npm run db:seed

echo ""
echo "✨ セットアップ完了！"
echo "   npm run dev でサーバーを起動してください"
echo "   http://localhost:3000 でアクセスできます"
```

---

## よくある質問（FAQ）

### Q: ローカルでサーバーが起動しない

```bash
# ポートの確認
lsof -i :3000

# Dockerコンテナの確認
docker compose ps
docker compose logs

# 依存関係の再インストール
rm -rf node_modules && npm ci
```

### Q: テストが失敗する

```bash
# DBのリセット
npm run db:reset

# テスト用DBでのみ実行
NODE_ENV=test npm test
```

### Q: PRのCIが失敗する

1. ローカルで `npm run lint` と `npm test` を実行
2. エラーを修正してコミット
3. CIログを確認（GitHub Actions タブ）

---

## 重要リンク集

| リソース | URL |
|---------|-----|
| リポジトリ | [GitHub URL] |
| ドキュメント | [GitHub Pages URL] |
| CI/CD | [GitHub Actions URL] |
| 監視ダッシュボード | [Grafana/Datadog URL] |
| Slack チャンネル | #dev-general |
| チームカレンダー | [Google Calendar URL] |

---

## 関連ドキュメント

- [クイックスタート](../01_システム概要(SystemOverview)/04_クイックスタート(QuickStart).md)
- [コーディング規約](./02_コーディング規約(CodingStandards).md)
- [ナレッジベース管理](./04_ナレッジベース管理(KnowledgeBaseManagement).md)
