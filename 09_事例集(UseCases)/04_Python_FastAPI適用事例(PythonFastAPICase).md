# 04 Python / FastAPI プロジェクトへの適用事例（Python FastAPI Case）

---

## プロジェクト概要

| 項目 | 内容 |
|------|------|
| **プロジェクト種別** | Python / FastAPI REST API |
| **規模** | 約12,000行（エンドポイント25本・サービス18本・pytest 650本） |
| **実行期間** | 3日間（Triple Loop × 6サイクル） |
| **使用モデル** | claude-sonnet-4-5（通常）・claude-opus-4-6（設計確認） |
| **達成タスク** | 18タスク |

---

## 実行前の課題

```
pytest カバレッジ: 58%  ← 目標: 85%
mypy エラー: 89件
ruff エラー: 134件
パフォーマンス問題: 3件（Celery タスクのメモリリーク含む）
セキュリティ問題: 2件（SQLインジェクションリスク）
```

---

## Python 特有の settings.json 設定

```json
{
  "model": "claude-sonnet-4-5",
  "permissions": {
    "allow": ["Read", "Write", "Edit", "bash", "Glob", "Grep"],
    "deny": ["bash(rm -rf /*)", "bash(DROP TABLE*)"]
  },
  "autoApprove": {
    "enabled": true,
    "rules": [
      { "tool": "Read", "auto": true },
      { "tool": "bash", "pattern": "pytest.*",           "auto": true },
      { "tool": "bash", "pattern": "ruff (check|format).*", "auto": true },
      { "tool": "bash", "pattern": "mypy .*",            "auto": true },
      { "tool": "bash", "pattern": "pip install .*",     "auto": false }
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": { "tool_name": "Write", "tool_input": ".*\\.py$" },
        "hooks": [{
          "type": "command",
          "command": "ruff format $CLAUDE_FILE_PATH && ruff check $CLAUDE_FILE_PATH --fix --quiet 2>/dev/null || true"
        }]
      }
    ]
  }
}
```

---

## CLAUDE.md への Python 固有の設定追記

```markdown
## コーディング規約（Python）
- 言語: Python 3.11+
- フレームワーク: FastAPI 0.100+
- テスト: pytest + httpx + pytest-asyncio
- 型チェック: mypy（strict モード）
- Lint: ruff（format + check）
- 依存管理: uv または pip

## 品質基準
- pytest カバレッジ: 85% 以上
- mypy エラー: 0件（strict モード）
- ruff エラー: 0件

## 禁止事項
- SQLAlchemy の raw SQL は使用不可（ORM のみ）
- `Any` 型の使用は最小限に（最大5%以下）
- 非同期関数に同期I/Oを混在させない
```

---

## 実行結果（3日間）

| 指標 | 開始 | Day1 | Day2 | Day3 |
|------|------|------|------|------|
| pytest カバレッジ | 58% | 71% | 82% | **88%** ✅ |
| mypy エラー | 89件 | 31件 | 8件 | **0件** ✅ |
| ruff エラー | 134件 | 42件 | 0件 | **0件** ✅ |
| セキュリティ問題 | 2件 | 2件 | 0件 | **0件** ✅ |
| パフォーマンス問題 | 3件 | 1件 | 0件 | **0件** ✅ |

---

## Celery メモリリーク修正の事例

```
# Claude Code へのプロンプト
Celery ワーカーが12時間後にメモリを2GB以上消費しています。
worker/tasks.py を調査して根本原因を特定し、修正してください。
```

**Claude の分析と修正:**
- ループ内でデータベース接続が閉じられていなかった
- `db.session.close()` の呼び忘れを全タスクに追加
- `@app.task(bind=True, max_retries=3)` でリトライ制御を追加

---

## 学んだベストプラクティス（Python編）

### ruff の Hooks 設定は必須

Python 開発では `PostToolUse/Write` で ruff を自動実行することで、PEP8違反が蓄積しません。

### mypy の段階的な strict 化

一度に全エラーを直すのではなく、モジュール単位で `# type: ignore` を外しながら進めると安定します。

### pytest-cov + threshold設定

```python
# pytest.ini
[pytest]
addopts = --cov=app --cov-report=term-missing --cov-fail-under=85
```

この設定でテストカバレッジが85%を下回るとテストが失敗するため、Claudeが自動的にテストを追加します。

---

## 参考

- [Hooks設定ガイド](../02_起動・設定(StartupConfig)/06_Hooks設定ガイド(HooksConfig).md)
- [settings.json設定ガイド](../02_起動・設定(StartupConfig)/07_settings_json設定ガイド(SettingsJson).md)
