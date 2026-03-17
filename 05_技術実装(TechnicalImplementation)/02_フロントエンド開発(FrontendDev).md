# 11 フロントエンド開発（Frontend Development）

## Claude Code 起動コマンド

```bash
claude --dangerously-skip-permissions
```

## プロンプト指示

```
以下の UI コンポーネント / 画面を実装してください。

【実装対象】
- フレームワーク: [React / Next.js / Vue / Svelte など]
- UI ライブラリ: [Tailwind CSS / shadcn/ui / MUI / Ant Design など]
- 状態管理: [Zustand / Redux / Pinia / Jotai など]
- 画面 / コンポーネント名: [NAME]
- デザイン参考: [Figma URL / スクリーンショット / テキスト説明]

【実装要件（DevUI / QA Agent が担当）】
- レスポンシブデザイン（モバイル / タブレット / デスクトップ）
- アクセシビリティ（WCAG 2.1 AA 準拠）
- ローディング状態・エラー状態・空状態の UI
- アニメーション / トランジション

【実行してほしいこと】
1. コンポーネント設計（props インターフェース・状態設計）を提示する
2. コンポーネントを実装する
3. Storybook ストーリーを作成する（Storybook が導入済みの場合）
4. スナップショットテスト / インタラクションテストを作成する
5. アクセシビリティチェック（axe-core）を実行する
6. Lighthouse でパフォーマンス・アクセシビリティスコアを確認する
7. git commit（feat: [コンポーネント名] を実装）する

【完了基準】
- Lighthouse スコア 90 以上（Performance / Accessibility / Best Practices）
- テストがすべてパス
- 既存コンポーネントとデザインが統一されている
```

## 使用場面

- 新規画面の実装
- デザインシステムのコンポーネント追加
- UI の改善・リニューアル

## ポイント

- デザイン参考を具体的に与えるほど意図に近い実装が生成される
