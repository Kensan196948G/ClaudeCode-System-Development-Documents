# 04 クイックスタート（Quick Start）

---

## 5分ではじめる ClaudeCode 自律開発

---

## ステップ 1: 前提条件の確認

```bash
# Claude Code CLI のバージョン確認
claude --version

# Git の確認
git --version

# GitHub CLI の確認
gh --version
gh auth status
```

**必要なもの:**
- Claude Code CLI（最新版）
- Git 2.x 以上
- GitHub アカウント・リポジトリ
- Anthropic API キー

---

## ステップ 2: Claude Code のインストール

```bash
# npm でグローバルインストール
npm install -g @anthropic-ai/claude-code

# バージョン確認
claude --version

# 認証設定
claude auth login
```

> **API キーについて**: `claude auth login` 実行後、Anthropic コンソール (https://console.anthropic.com) で取得した API キーを入力してください。

---

## ステップ 3: VS Code 拡張機能のセットアップ（推奨）

```bash
# VS Code 拡張機能をインストール（オプション）
code --install-extension anthropic.claude-code

# または Claude Code CLI 経由で自動設定
claude setup vscode
```

VS Code を使用する場合は拡張機能でサイドバー表示・インラインdiffが利用できます。
詳細は [VS Code拡張機能](../01_システム概要(SystemOverview)/06_VSCode拡張機能(VSCodeExtension).md) を参照。

---

## ステップ 4: .claude/ ディレクトリの作成と設定

```bash
# プロジェクトルートに .claude/ ディレクトリ作成
mkdir -p .claude/commands .claude/hooks .claude/mcp-configs

# 基本的な settings.json を作成
cat > .claude/settings.json << 'EOF'
{
  "model": "claude-sonnet-4-5",
  "permissions": {
    "allow": ["Read", "Write", "Edit", "bash", "Glob", "Grep"],
    "deny": ["bash(sudo rm -rf*)"]
  },
  "autoApprove": {
    "enabled": true,
    "rules": [
      { "tool": "Read", "auto": true },
      { "tool": "bash", "pattern": "npm (test|lint|build).*", "auto": true }
    ]
  },
  "session": {
    "checkpointsEnabled": true
  }
}
EOF
```

---

## ステップ 5: CLAUDE.md の配置

システムの頭脳となる設定ファイルを配置します。

```bash
# ~/.claude/ ディレクトリ作成（グローバル設定）
mkdir -p ~/.claude

# CLAUDE.md を配置（01_フル自律開発起動 の内容を参照）
cp /path/to/CLAUDE.md ~/.claude/CLAUDE.md
```

> **ポイント**: `~/.claude/CLAUDE.md` は Claude Code 起動時に自動で読み込まれます。
> プロジェクト内に `.claude/CLAUDE.md` を置くとプロジェクト固有設定として優先されます。

---

## ステップ 6: Triple Loop スクリプトの準備

```bash
# スクリプトに実行権限を付与
chmod +x triple-loop-15h.sh

# 内容確認
cat triple-loop-15h.sh | head -30
```

---

```bash
# 既存リポジトリをクローン
git clone https://github.com/your-org/your-project.git
cd your-project

# または新規プロジェクト初期化
# → 03_開発シナリオ/01_新規プロジェクト初期化(NewProjectInit).md を参照
```

---

## ステップ 8: 自律開発ループ起動

```bash
# Triple Loop 15H を起動（15時間自律ループ）
./triple-loop-15h.sh

# または Claude Code に直接プロンプトを渡す
claude "00_フル自律開発起動(FullAutoStart).md の内容でシステムを起動してください"
```

---

## よく使う起動コマンド

| シナリオ | 参照ファイル |
|---------|------------|
| フル自律開発 | `02_起動・設定/01_フル自律開発起動(FullAutoStart).md` |
| 新機能開発 | `03_開発シナリオ/01_新規プロジェクト初期化(NewProjectInit).md` |
| バグ修正 | `03_開発シナリオ/02_バグ修正(BugFix).md` |
| コードレビュー | `03_開発シナリオ/03_コードレビュー(CodeReview).md` |
| CI/CD構築 | `04_インフラ・DevOps/01_CI_CD構築(CICDSetup).md` |
| セキュリティ診断 | `04_インフラ・DevOps/02_セキュリティ診断(SecurityAudit).md` |
| インシデント対応 | `06_保守・移行/03_インシデント対応(IncidentResponse).md` |
| Hooks 設定 | `02_起動・設定/06_Hooks設定ガイド(HooksConfig).md` |
| MCP 外部連携 | `02_起動・設定/08_MCP設定ガイド(MCPConfig).md` |

---

## トラブルシューティング

### Claude Code が応答しない

```bash
# プロセス確認
ps aux | grep claude

# ログ確認
cat ~/.claude/logs/latest.log
```

### チェックポイントから元に戻したい

```bash
# Claude Code セッション内で
/rewind
# または Esc × 2 キー
```

詳細は [チェックポイント機能](../01_システム概要(SystemOverview)/05_チェックポイント機能(Checkpoints).md) を参照してください。

### API レート制限エラー

- ループ間隔を延長する（`triple-loop-15h.sh` の `SLEEP_INTERVAL` を調整）
- API プランをアップグレードする

### Git 権限エラー

```bash
# GitHub 認証状態確認
gh auth status

# トークンを再認証
gh auth login
```

---

## 次のステップ

- [アーキテクチャ概要](../01_システム概要(SystemOverview)/02_アーキテクチャ概要(ArchitectureOverview).md) — システム全体の仕組みを理解
- [エージェント構成](../01_システム概要(SystemOverview)/03_エージェント構成(AgentConfiguration).md) — 7体エージェントの役割を確認
- [利用ガイド](../01_システム概要(SystemOverview)/01_利用ガイド(UsageGuide).md) — 詳細な使い方を確認
- [チェックポイント機能](../01_システム概要(SystemOverview)/05_チェックポイント機能(Checkpoints).md) — /rewind の使い方
- [VS Code拡張機能](../01_システム概要(SystemOverview)/06_VSCode拡張機能(VSCodeExtension).md) — IDE統合の設定
- [Hooks設定ガイド](./06_Hooks設定ガイド(HooksConfig).md) — 開発ワークフロー自動化
- [MCP設定ガイド](./08_MCP設定ガイド(MCPConfig).md) — 外部ツール連携
