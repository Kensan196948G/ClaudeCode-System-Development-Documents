# ClaudeCode-System-Development-Documents

Claude Code による自律型ソフトウェア開発システムのドキュメント集。  
**Triple Loop アーキテクチャ**、7体エージェントチーム、Claude 4.x 最新機能、  
エンタープライズ対応、Anthropic API/SDK 活用まで体系的に整理しています。

> 最終更新: 2026-05-12 | 対応バージョン: Claude Opus 4.7 / Sonnet 4.6 / Haiku 4.5

---

## クイックナビゲーション

| やりたいこと | 参照ドキュメント |
|------------|--------------|
| すぐに起動したい | [クイックスタート](./01_システム概要(SystemOverview)/04_クイックスタート(QuickStart).md) |
| 仕組みを知りたい | [アーキテクチャ概要](./01_システム概要(SystemOverview)/02_アーキテクチャ概要(ArchitectureOverview).md) |
| 最新モデルを使いたい | [Claude 4.x モデルガイド](./10_最新機能(LatestFeatures)/01_Claude4xモデルガイド(Claude4xModels).md) |
| 計画してから実装したい | [Plan Mode ガイド](./10_最新機能(LatestFeatures)/02_PlanMode計画モード(PlanMode).md) |
| 並列で開発したい | [Git Worktree ガイド](./10_最新機能(LatestFeatures)/03_GitWorktree並列開発(GitWorktree).md) |
| 記憶を永続化したい | [Memory システム](./10_最新機能(LatestFeatures)/04_Memoryシステム(MemorySystem).md) |
| 深く考えさせたい | [Extended Thinking](./10_最新機能(LatestFeatures)/05_ExtendedThinking拡張思考(ExtendedThinking).md) |
| 定期実行を自動化したい | [スケジューリング・Cron](./10_最新機能(LatestFeatures)/07_スケジューリング・Cron(Scheduling).md) |
| バグを直したい | [バグ修正](./03_開発シナリオ(DevelopmentScenarios)/02_バグ修正(BugFix).md) |
| 本番デプロイしたい | [デプロイ戦略](./04_インフラ・DevOps(InfraDevOps)/05_デプロイ戦略(DeploymentStrategy).md) |
| 障害対応したい | [インシデント対応](./06_保守・移行(MaintenanceMigration)/03_インシデント対応(IncidentResponse).md) |
| ツール動作を制御したい | [settings.json 設定ガイド](./02_起動・設定(StartupConfig)/07_settings_json設定ガイド(SettingsJson).md) |
| Slack/GitHub と連携したい | [MCP 設定ガイド](./02_起動・設定(StartupConfig)/08_MCP設定ガイド(MCPConfig).md) |
| 組織全体に展開したい | [エンタープライズセットアップ](./11_エンタープライズ(Enterprise)/01_エンタープライズセットアップ(EnterpriseSetup).md) |
| AWS/GCP で動かしたい | [Bedrock・Vertex デプロイ](./11_エンタープライズ(Enterprise)/02_Bedrock・Vertexデプロイ(BedrockVertex).md) |
| APIを使って開発したい | [Anthropic API 基礎](./12_API・SDK開発(APISDKDev)/01_AnthropicAPI基礎(AnthropicAPIBasics).md) |
| コストを削減したい | [Prompt Caching 最適化](./12_API・SDK開発(APISDKDev)/06_PromptCaching最適化(PromptCaching).md) |

---

## ドキュメント構成

### 📁 [01_システム概要(SystemOverview)](./01_システム概要(SystemOverview)/)
システム全体の概要・アーキテクチャ・エージェント構成を解説します。

| ファイル | 内容 |
|---------|------|
| [01_利用ガイド](./01_システム概要(SystemOverview)/01_利用ガイド(UsageGuide).md) | システム全体の使い方 |
| [02_アーキテクチャ概要](./01_システム概要(SystemOverview)/02_アーキテクチャ概要(ArchitectureOverview).md) | Triple Loop アーキテクチャ + 最新機能スタック |
| [03_エージェント構成](./01_システム概要(SystemOverview)/03_エージェント構成(AgentConfiguration).md) | 7体エージェントの役割と連携 |
| [04_クイックスタート](./01_システム概要(SystemOverview)/04_クイックスタート(QuickStart).md) | 5分ではじめるセットアップガイド |
| [05_チェックポイント機能](./01_システム概要(SystemOverview)/05_チェックポイント機能(Checkpoints).md) | /rewind・Esc×2 によるコード復元 |
| [06_VSCode拡張機能](./01_システム概要(SystemOverview)/06_VSCode拡張機能(VSCodeExtension).md) | VS Code / JetBrains ネイティブ拡張ガイド |
| [07_Claude_Agent_SDK](./01_システム概要(SystemOverview)/07_Claude_Agent_SDK(AgentSDK).md) | カスタムエージェント・SDK 活用ガイド |

---

### 📁 [02_起動・設定(StartupConfig)](./02_起動・設定(StartupConfig)/)
システム起動・設定ファイルの詳細解説です。

| ファイル | 内容 |
|---------|------|
| [01_フル自律開発起動](./02_起動・設定(StartupConfig)/01_フル自律開発起動(FullAutoStart).md) | Super Architecture + Triple Loop 起動設定 |
| [02_ループ監視プロンプト](./02_起動・設定(StartupConfig)/02_ループ監視プロンプト(LoopMonitorPrompt).md) | Monitor Loop プロンプト定義 |
| [03_ループ検証プロンプト](./02_起動・設定(StartupConfig)/03_ループ検証プロンプト(LoopVerifyPrompt).md) | Verify Loop プロンプト定義 |
| [04_TripleLoop起動スクリプト](./02_起動・設定(StartupConfig)/04_TripleLoop起動スクリプト(TripleLoopScript).md) | triple-loop-15h.sh の使い方 |
| [05_CLAUDE_MD設定ガイド](./02_起動・設定(StartupConfig)/05_CLAUDE_MD設定ガイド(CLAUDEMDConfig).md) | CLAUDE.md の書き方・設定例 |
| [06_Hooks設定ガイド](./02_起動・設定(StartupConfig)/06_Hooks設定ガイド(HooksConfig).md) | ライフサイクルHooksによる自動化 |
| [07_settings_json設定ガイド](./02_起動・設定(StartupConfig)/07_settings_json設定ガイド(SettingsJson).md) | ツール制御・自動承認・モデル設定 |
| [08_MCP設定ガイド](./02_起動・設定(StartupConfig)/08_MCP設定ガイド(MCPConfig).md) | 外部ツール連携（Slack/Jira/GitHub/DB/Notion/Gmail） |
| [09_サブエージェント設計](./02_起動・設定(StartupConfig)/09_サブエージェント設計(SubagentDesign).md) | 並列サブエージェントの設計・活用 |

---

### 📁 [03_開発シナリオ(DevelopmentScenarios)](./03_開発シナリオ(DevelopmentScenarios)/)
各開発タスクで使用する Claude Code プロンプト集です。

| ファイル | 内容 |
|---------|------|
| [01_新規プロジェクト初期化](./03_開発シナリオ(DevelopmentScenarios)/01_新規プロジェクト初期化(NewProjectInit).md) | 新規プロジェクトの立ち上げ |
| [02_バグ修正](./03_開発シナリオ(DevelopmentScenarios)/02_バグ修正(BugFix).md) | バグ調査・修正 |
| [03_コードレビュー](./03_開発シナリオ(DevelopmentScenarios)/03_コードレビュー(CodeReview).md) | コードレビュー支援 |
| [04_リファクタリング](./03_開発シナリオ(DevelopmentScenarios)/04_リファクタリング(Refactoring).md) | コード改善・整理 |
| [05_テスト自動化](./03_開発シナリオ(DevelopmentScenarios)/05_テスト自動化(TestAutomation).md) | テスト設計・実装 |
| [06_機能追加](./03_開発シナリオ(DevelopmentScenarios)/06_機能追加(FeatureAddition).md) | 新機能の設計・実装 |
| [07_コード解析](./03_開発シナリオ(DevelopmentScenarios)/07_コード解析(CodeAnalysis).md) | コード品質・問題点の分析 |

---

### 📁 [04_インフラ・DevOps(InfraDevOps)](./04_インフラ・DevOps(InfraDevOps)/)
CI/CD・インフラ・運用自動化のプロンプト集です。

| ファイル | 内容 |
|---------|------|
| [01_CI_CD構築](./04_インフラ・DevOps(InfraDevOps)/01_CI_CD構築(CICDSetup).md) | GitHub Actions パイプライン構築 |
| [02_セキュリティ診断](./04_インフラ・DevOps(InfraDevOps)/02_セキュリティ診断(SecurityAudit).md) | セキュリティ脆弱性スキャン |
| [03_パフォーマンス最適化](./04_インフラ・DevOps(InfraDevOps)/03_パフォーマンス最適化(PerformanceOpt).md) | パフォーマンス計測・改善 |
| [04_環境構築](./04_インフラ・DevOps(InfraDevOps)/04_環境構築(EnvironmentSetup).md) | 開発・本番環境のセットアップ |
| [05_デプロイ戦略](./04_インフラ・DevOps(InfraDevOps)/05_デプロイ戦略(DeploymentStrategy).md) | Blue-Green / Canary デプロイ |
| [06_コンテナ化](./04_インフラ・DevOps(InfraDevOps)/06_コンテナ化(Containerization).md) | Docker / Kubernetes 化 |

---

### 📁 [05_技術実装(TechnicalImplementation)](./05_技術実装(TechnicalImplementation)/)
技術実装に特化したプロンプト集です。

| ファイル | 内容 |
|---------|------|
| [01_APIサーバー構築](./05_技術実装(TechnicalImplementation)/01_APIサーバー構築(APIServerBuild).md) | REST/GraphQL API 実装 |
| [02_フロントエンド開発](./05_技術実装(TechnicalImplementation)/02_フロントエンド開発(FrontendDev).md) | React/Vue フロントエンド開発 |
| [03_データベース設計](./05_技術実装(TechnicalImplementation)/03_データベース設計(DatabaseDesign).md) | ER設計・マイグレーション |
| [04_認証・認可設計](./05_技術実装(TechnicalImplementation)/04_認証・認可設計(AuthDesign).md) | JWT / OAuth2 / RBAC 実装 |
| [05_マイクロサービス設計](./05_技術実装(TechnicalImplementation)/05_マイクロサービス設計(MicroserviceDesign).md) | マイクロサービスアーキテクチャ |

---

### 📁 [06_保守・移行(MaintenanceMigration)](./06_保守・移行(MaintenanceMigration)/)
保守・運用・移行のプロンプト集です。

| ファイル | 内容 |
|---------|------|
| [01_レガシーコード移行](./06_保守・移行(MaintenanceMigration)/01_レガシーコード移行(LegacyMigration).md) | 旧システムのモダン化 |
| [02_依存関係更新](./06_保守・移行(MaintenanceMigration)/02_依存関係更新(DependencyUpdate).md) | ライブラリ・フレームワーク更新 |
| [03_インシデント対応](./06_保守・移行(MaintenanceMigration)/03_インシデント対応(IncidentResponse).md) | 障害対応・復旧手順 |
| [04_技術的負債管理](./06_保守・移行(MaintenanceMigration)/04_技術的負債管理(TechDebtManagement).md) | 技術的負債の可視化・返済計画 |
| [05_バックアップ・復旧](./06_保守・移行(MaintenanceMigration)/05_バックアップ・復旧(BackupRecovery).md) | データバックアップ・DR対応 |

---

### 📁 [07_ドキュメント・ナレッジ(DocumentationKnowledge)](./07_ドキュメント・ナレッジ(DocumentationKnowledge)/)
ドキュメント作成・ナレッジ管理のプロンプト集です。

| ファイル | 内容 |
|---------|------|
| [01_ドキュメント生成](./07_ドキュメント・ナレッジ(DocumentationKnowledge)/01_ドキュメント生成(DocGeneration).md) | 技術文書の自動生成 |
| [02_コーディング規約](./07_ドキュメント・ナレッジ(DocumentationKnowledge)/02_コーディング規約(CodingStandards).md) | チームのコーディング標準 |
| [03_設計ドキュメント作成](./07_ドキュメント・ナレッジ(DocumentationKnowledge)/03_設計ドキュメント作成(DesignDocCreation).md) | 設計書・API仕様書の作成 |
| [04_ナレッジベース管理](./07_ドキュメント・ナレッジ(DocumentationKnowledge)/04_ナレッジベース管理(KnowledgeBaseManagement).md) | ADR・ポストモーテム・FAQ管理 |
| [05_チームオンボーディング](./07_ドキュメント・ナレッジ(DocumentationKnowledge)/05_チームオンボーディング(TeamOnboarding).md) | 新メンバー向けガイド |
| [06_メトリクスレポートテンプレート](./07_ドキュメント・ナレッジ(DocumentationKnowledge)/06_メトリクスレポートテンプレート(MetricsReport).md) | 週次/月次活用状況レポートテンプレート |

---

### 📁 [08_チュートリアル(Tutorials)](./08_チュートリアル(Tutorials)/)
ステップバイステップの操作ガイドです。実際に手を動かしながら学べます。

| ファイル | 内容 |
|---------|------|
| [01_初めてのTripleLoop実行](./08_チュートリアル(Tutorials)/01_初めてのTripleLoop実行(FirstTripleLoop).md) | Triple Loop 15H の初回起動手順 |
| [02_VSCode拡張機能活用](./08_チュートリアル(Tutorials)/02_VSCode拡張機能活用(VSCodeTutorial).md) | インラインdiff・サイドバーの使い方 |
| [03_Hooks実践設定](./08_チュートリアル(Tutorials)/03_Hooks実践設定(HooksPractice).md) | 自動テスト・ブロック・通知のHooks設定 |
| [04_MCP連携入門](./08_チュートリアル(Tutorials)/04_MCP連携入門(MCPIntro).md) | GitHub MCP の設定と使い方 |
| [05_サブエージェント並列実行](./08_チュートリアル(Tutorials)/05_サブエージェント並列実行(SubagentParallel).md) | 並列サブエージェントによる高速開発 |

---

### 📁 [09_事例集(UseCases)](./09_事例集(UseCases)/)
実際のプロジェクトでの適用事例・成功パターン・失敗から学んだことをまとめています。

| ファイル | 内容 |
|---------|------|
| [01_NodeJS_REST_API適用事例](./09_事例集(UseCases)/01_NodeJS_REST_API適用事例(NodeJSRestAPICase).md) | Node.js/TS API への Triple Loop 適用 |
| [02_React_フロントエンド適用事例](./09_事例集(UseCases)/02_React_フロントエンド適用事例(ReactFrontendCase).md) | React 18 移行・大規模型付け事例 |
| [03_インシデント対応活用事例](./09_事例集(UseCases)/03_インシデント対応活用事例(IncidentResponseCase).md) | 深夜インシデントを45分で解決 |
| [04_Python_FastAPI適用事例](./09_事例集(UseCases)/04_Python_FastAPI適用事例(PythonFastAPICase).md) | Python/FastAPI でのカバレッジ 58%→88% |
| [05_セキュリティ脆弱性対応事例](./09_事例集(UseCases)/05_セキュリティ脆弱性対応事例(SecurityResponseCase).md) | Critical CVE を 2.5 時間で修正・再発防止 |

---

### 🆕 📁 [10_最新機能(LatestFeatures)](./10_最新機能(LatestFeatures)/)
Claude Code 2025年の最新機能を解説します。

| ファイル | 内容 |
|---------|------|
| [01_Claude4xモデルガイド](./10_最新機能(LatestFeatures)/01_Claude4xモデルガイド(Claude4xModels).md) | Opus 4.7 / Sonnet 4.6 / Haiku 4.5 の使い分け |
| [02_PlanMode計画モード](./10_最新機能(LatestFeatures)/02_PlanMode計画モード(PlanMode).md) | 計画→承認→実装の安全ワークフロー |
| [03_GitWorktree並列開発](./10_最新機能(LatestFeatures)/03_GitWorktree並列開発(GitWorktree).md) | 複数ブランチの同時並列開発 |
| [04_Memoryシステム](./10_最新機能(LatestFeatures)/04_Memoryシステム(MemorySystem).md) | セッション横断の永続記憶機能 |
| [05_ExtendedThinking拡張思考](./10_最新機能(LatestFeatures)/05_ExtendedThinking拡張思考(ExtendedThinking).md) | 深い推論・複雑問題解決モード |
| [06_WebSearch・Vision](./10_最新機能(LatestFeatures)/06_WebSearch・Vision(WebSearchVision).md) | リアルタイム Web 検索と画像理解 |
| [07_スケジューリング・Cron](./10_最新機能(LatestFeatures)/07_スケジューリング・Cron(Scheduling).md) | /loop・/schedule・CronCreate・ScheduleWakeup |
| [08_カスタムスキル開発](./10_最新機能(LatestFeatures)/08_カスタムスキル開発(CustomSkills).md) | プロジェクト固有スラッシュコマンドの作成 |

---

### 🆕 📁 [11_エンタープライズ(Enterprise)](./11_エンタープライズ(Enterprise)/)
組織全体への展開・セキュリティ・コンプライアンス対応のガイド集です。

| ファイル | 内容 |
|---------|------|
| [01_エンタープライズセットアップ](./11_エンタープライズ(Enterprise)/01_エンタープライズセットアップ(EnterpriseSetup).md) | SSO・SCIM・チームポリシー・コスト管理 |
| [02_Bedrock・Vertexデプロイ](./11_エンタープライズ(Enterprise)/02_Bedrock・Vertexデプロイ(BedrockVertex).md) | AWS Bedrock / GCP Vertex AI でのホスティング |
| [03_ネットワーク分離・セキュリティ](./11_エンタープライズ(Enterprise)/03_ネットワーク分離・セキュリティ(NetworkSecurity).md) | 許可ホスト管理・権限制限・シークレット保護 |
| [04_監査ログ・コンプライアンス](./11_エンタープライズ(Enterprise)/04_監査ログ・コンプライアンス(AuditCompliance).md) | 全操作記録・SOC2/ISO27001/GDPR 対応 |

---

### 🆕 📁 [12_API・SDK開発(APISDKDev)](./12_API・SDK開発(APISDKDev)/)
Anthropic API と Claude Agent SDK を使ったアプリケーション開発のガイド集です。

| ファイル | 内容 |
|---------|------|
| [01_AnthropicAPI基礎](./12_API・SDK開発(APISDKDev)/01_AnthropicAPI基礎(AnthropicAPIBasics).md) | Messages API・認証・ストリーミング・エラーハンドリング |
| [02_ClaudeAgentSDK詳細](./12_API・SDK開発(APISDKDev)/02_ClaudeAgentSDK詳細(AgentSDK).md) | カスタムエージェント・マルチエージェントシステム構築 |
| [03_ツール使用（FunctionCalling）](./12_API・SDK開発(APISDKDev)/03_ツール使用（FunctionCalling）(ToolUse).md) | Tool Use・tool_choice・並列ツール呼び出し |
| [04_BatchAPI大量処理](./12_API・SDK開発(APISDKDev)/04_BatchAPI大量処理(BatchAPI).md) | 非同期バッチ処理（50% 割引）・大量分析 |
| [05_FilesAPI管理](./12_API・SDK開発(APISDKDev)/05_FilesAPI管理(FilesAPI).md) | ファイルアップロード・再利用・コスト削減 |
| [06_PromptCaching最適化](./12_API・SDK開発(APISDKDev)/06_PromptCaching最適化(PromptCaching).md) | キャッシュで最大 90% コスト削減 |

---

### 📁 [templates/](./templates/)
すぐに使える `.claude/` ディレクトリのテンプレートファイル集。新規プロジェクトにコピーして利用できます。

| ファイル/フォルダ | 内容 |
|---------|------|
| [templates/.claude/CLAUDE.md](./templates/.claude/CLAUDE.md) | Triple Loop プロジェクトテンプレート |
| [templates/.claude/settings.json](./templates/.claude/settings.json) | ツール制御・Hooks・自動承認の設定例 |
| [templates/.claude/commands/review.md](./templates/.claude/commands/review.md) | `/review` カスタムコマンド定義 |
| [templates/.claude/commands/deploy.md](./templates/.claude/commands/deploy.md) | `/deploy` カスタムコマンド定義 |
| [templates/.claude/hooks/post-write.sh](./templates/.claude/hooks/post-write.sh) | ファイル変更後フック（Lint自動実行） |
| [templates/.claude/hooks/pre-commit.sh](./templates/.claude/hooks/pre-commit.sh) | コミット前品質チェック |

---

### 🌐 多言語ドキュメント（Multilingual Docs）

| 言語 | リンク | 概要 |
|------|--------|------|
| 🇺🇸 English | [docs-en/README.md](./docs-en/README.md) | System overview & QuickStart |
| 🇨🇳 简体中文 | [docs-zh/README.md](./docs-zh/README.md) | 系统概述与快速入门 |
| 🇰🇷 한국어 | [docs-ko/README.md](./docs-ko/README.md) | 시스템 개요 및 빠른 시작 |

**docs-en/ 詳細**

| File | Content |
|------|---------|
| [README](./docs-en/README.md) | System overview in English |
| [QuickStart](./docs-en/QuickStart.md) | 5-minute setup guide |
| [ArchitectureOverview](./docs-en/ArchitectureOverview.md) | Triple Loop architecture |
| [HooksGuide](./docs-en/HooksGuide.md) | Hooks configuration guide |
| [MCPGuide](./docs-en/MCPGuide.md) | MCP integration guide |
| [SettingsGuide](./docs-en/SettingsGuide.md) | settings.json configuration |

---

## 対応 Claude Code 機能マップ

```
Claude Code 最新機能                    ドキュメント
─────────────────────────────────────────────────────────
Claude 4.x Models (Opus/Sonnet/Haiku) → 10/01
Plan Mode (EnterPlanMode)             → 10/02
Git Worktree (EnterWorktree)          → 10/03
Memory System (MEMORY.md)             → 10/04
Extended Thinking                     → 10/05
Web Search / Vision                   → 10/06
/loop / /schedule / CronCreate        → 10/07
Custom Skills (.claude/commands/)     → 10/08
Enterprise: SSO/SCIM                  → 11/01
AWS Bedrock / GCP Vertex              → 11/02
Network Isolation                     → 11/03
Audit Logging                         → 11/04
Messages API / Streaming              → 12/01
Agent SDK / Tool Use                  → 12/02-03
Batch API (50% off)                   → 12/04
Files API                             → 12/05
Prompt Caching (90% off)              → 12/06
Triple Loop Architecture              → 01/02, 02/01-04
Hooks (PreToolUse/PostToolUse/...)    → 02/06, 08/03
MCP (Slack/GitHub/Notion/Gmail/...)   → 02/08, 08/04
Sub-agents (parallel)                 → 02/09, 08/05
CLAUDE.md / settings.json             → 02/05, 02/07
VS Code / JetBrains Extension         → 01/06, 08/02
Checkpoints (/rewind)                 → 01/05
```

---

## ライセンス

[MIT License](./LICENSE)
