#!/bin/bash
# pre-commit.sh — コミット前チェックスクリプト
# settings.json の PreToolUse/bash("git commit.*") hook から呼び出す

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="/tmp/claude-activity.log"

echo "[$TIMESTAMP] PRE-COMMIT CHECK 開始" >> "$LOG_FILE"

# Lintチェック
if [ -f "package.json" ]; then
  echo "npm run lint を実行中..."
  if ! npm run lint --silent 2>&1; then
    echo "[$TIMESTAMP] PRE-COMMIT FAILED: Lintエラー" >> "$LOG_FILE"
    echo "❌ コミット失敗: Lintエラーを修正してください"
    exit 1
  fi
fi

# TypeScriptの型チェック
if [ -f "tsconfig.json" ]; then
  echo "TypeScript型チェックを実行中..."
  if ! npx tsc --noEmit --quiet 2>&1; then
    echo "[$TIMESTAMP] PRE-COMMIT FAILED: TypeScriptエラー" >> "$LOG_FILE"
    echo "❌ コミット失敗: TypeScriptエラーを修正してください"
    exit 1
  fi
fi

# Pythonの場合
if [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
  if command -v ruff &>/dev/null; then
    echo "ruff check を実行中..."
    if ! ruff check . --quiet 2>&1; then
      echo "[$TIMESTAMP] PRE-COMMIT FAILED: ruffエラー" >> "$LOG_FILE"
      echo "❌ コミット失敗: ruffエラーを修正してください"
      exit 1
    fi
  fi
fi

echo "[$TIMESTAMP] PRE-COMMIT CHECK 完了" >> "$LOG_FILE"
echo "✅ コミット前チェック完了"
exit 0
