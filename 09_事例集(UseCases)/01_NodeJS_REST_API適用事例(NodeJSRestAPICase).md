# 01 Node.js REST API プロジェクトへの適用事例（NodeJS REST API Case）

---

## プロジェクト概要

| 項目 | 内容 |
|------|------|
| **プロジェクト種別** | Node.js / TypeScript REST API |
| **規模** | 約15,000行（コントローラー30本・サービス20本・テスト800本） |
| **実行期間** | 2日間（Triple Loop × 4サイクル） |
| **使用モデル** | claude-sonnet-4-5 |
| **達成タスク** | 12タスク（バグ修正5・新機能4・リファクタリング3） |

---

## 実行前の状況

```
テストカバレッジ: 62%  ← 目標: 80%
TypeScriptエラー: 23件
ESLintエラー: 47件
未解決バグ: 8件（GitHub Issues）
```

---

## 使用した設定

### `.claude/settings.json`

```json
{
  "model": "claude-sonnet-4-5",
  "permissions": {
    "allow": ["Read", "Write", "Edit", "bash", "Glob", "Grep"],
    "deny": ["bash(rm -rf /*)", "bash(git push --force*)"]
  },
  "autoApprove": {
    "enabled": true,
    "rules": [
      { "tool": "Read", "auto": true },
      { "tool": "bash", "pattern": "npm (test|lint|build).*", "auto": true },
      { "tool": "bash", "pattern": "git (add|commit|status|log).*", "auto": true }
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": { "tool_name": "Write" },
        "hooks": [{
          "type": "command",
          "command": "npx eslint $CLAUDE_FILE_PATH --fix --quiet 2>/dev/null || true"
        }]
      }
    ]
  },
  "session": { "checkpointsEnabled": true }
}
```

---

## 実行結果

### Day 1（サイクル 1〜2: 30H）

**Monitor Loop の分析結果:**
- TypeScriptエラー: 23件（主に `any` 型と型不一致）
- Lintエラー: 47件（未使用変数・コメントアウトコード）
- 未解決バグ: 8件（GitHub Issues から自動取得）

**Build Loop の成果:**
- TypeScriptエラー: 23件 → **0件** ✅
- ESLintエラー: 47件 → **0件** ✅
- バグ修正: 5件完了（Issues #12, #15, #18, #23, #27）

**Verify Loop の結果:**
- テスト: 800件すべて通過 ✅
- セキュリティスキャン: 問題なし ✅

---

### Day 2（サイクル 3〜4: 30H）

**Build Loop の成果（新機能）:**
- ユーザー認証機能（JWT）の実装
- 権限管理（RBAC）の実装
- APIレート制限の実装
- Webhook 通知機能の実装

**テストカバレッジ推移:**
```
開始時: 62%
Day1終了: 74%
Day2終了: 86% ✅（目標 80% 達成）
```

---

## 失敗から学んだこと

### 課題1: 自動承認しすぎた結果、不要なパッケージが追加された

**状況**: `npm install xxx` が自動承認され、不要なパッケージが追加された  
**対処**: `/rewind` で直前のチェックポイントに戻し、設定を修正

```json
// 追加した禁止ルール
{ "deny": ["bash(npm install (?!--save-dev).*@latest)"] }
```

### 課題2: テスト修正が実装の修正より先に進んだ

**状況**: テストを先に「通過するよう修正」されたが、実装の問題は残ったまま  
**対処**: CLAUDE.md に「テストの期待値は変更しないこと」を明記

```markdown
## 禁止事項
- テストコードの期待値（expected値）を変更してテストを通過させることは禁止
```

---

## 推奨設定の改善点

この事例から生まれた改善点を `templates/.claude/` に反映済みです。

---

## 参考

- 使用した起動プロンプト: [01_フル自律開発起動](../02_起動・設定(StartupConfig)/01_フル自律開発起動(FullAutoStart).md)
- 適用したHooks: [06_Hooks設定ガイド](../02_起動・設定(StartupConfig)/06_Hooks設定ガイド(HooksConfig).md)
