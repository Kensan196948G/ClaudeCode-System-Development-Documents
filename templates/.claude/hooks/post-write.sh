#!/bin/bash
# post-write.sh — ファイル書き込み後に実行されるHookスクリプト
# settings.json の PostToolUse/Write hook から呼び出す

FILE_PATH="${CLAUDE_FILE_PATH:-unknown}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
LOG_FILE="/tmp/claude-activity.log"

echo "[$TIMESTAMP] WRITE: $FILE_PATH" >> "$LOG_FILE"

# TypeScript/JavaScriptファイルの場合はLintを実行
if [[ "$FILE_PATH" =~ \.(ts|tsx|js|jsx)$ ]]; then
  if command -v npx &>/dev/null; then
    npx eslint "$FILE_PATH" --fix --quiet 2>/dev/null
  fi
fi

# Pythonファイルの場合はruffでフォーマット
if [[ "$FILE_PATH" =~ \.py$ ]]; then
  if command -v ruff &>/dev/null; then
    ruff format "$FILE_PATH" 2>/dev/null
  fi
fi

exit 0
