# ClaudeCode-System-Development-Documents

ClaudeCode による自律型ソフトウェア開発システムのドキュメント集。  
Triple Loop アーキテクチャ、7体エージェントチーム、Monitor/Build/Verify ループ、  
AI 自動開発のベストプラクティスを体系的に整理しています。

---

## ドキュメント構成

### 📁 [01_システム概要(SystemOverview)](./01_システム概要(SystemOverview)/)
システム全体の概要・アーキテクチャ・エージェント構成を解説します。

| ファイル | 内容 |
|---------|------|
| [01_利用ガイド](./01_システム概要(SystemOverview)/01_利用ガイド(UsageGuide).md) | システム全体の使い方 |
| [02_アーキテクチャ概要](./01_システム概要(SystemOverview)/02_アーキテクチャ概要(ArchitectureOverview).md) | Triple Loop アーキテクチャの解説 |
| [03_エージェント構成](./01_システム概要(SystemOverview)/03_エージェント構成(AgentConfiguration).md) | 7体エージェントの役割と連携 |
| [04_クイックスタート](./01_システム概要(SystemOverview)/04_クイックスタート(QuickStart).md) | 5分ではじめるセットアップガイド |

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

---

## クイックリファレンス

| やりたいこと | 参照ドキュメント |
|------------|--------------|
| すぐに起動したい | [クイックスタート](./01_システム概要(SystemOverview)/04_クイックスタート(QuickStart).md) |
| 仕組みを知りたい | [アーキテクチャ概要](./01_システム概要(SystemOverview)/02_アーキテクチャ概要(ArchitectureOverview).md) |
| バグを直したい | [バグ修正](./03_開発シナリオ(DevelopmentScenarios)/02_バグ修正(BugFix).md) |
| 本番デプロイしたい | [デプロイ戦略](./04_インフラ・DevOps(InfraDevOps)/05_デプロイ戦略(DeploymentStrategy).md) |
| 障害対応したい | [インシデント対応](./06_保守・移行(MaintenanceMigration)/03_インシデント対応(IncidentResponse).md) |

---

## ライセンス

[MIT License](./LICENSE)

