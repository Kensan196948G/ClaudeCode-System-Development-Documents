#!/bin/bash
#═══════════════════════════════════════════════════════════════
#  triple-loop-15h.sh
#  Triple Loop 15H (2-Cycle) — Claude Code のみ
#  Monitor(30m) → CD1(10m) → Build(2h) → CD2(20m) → Verify(4h)
#  × 2サイクル + CD3(30m) + 最終処理(30m) = 15H
#═══════════════════════════════════════════════════════════════
#
#  アーキテクチャ:
#    Cycle 1: Monitor → CD1 → Build → CD2 → Verify  (7h)
#    CD3: 30分クールダウン
#    Cycle 2: Monitor → CD1 → Build → CD2 → Verify  (7h)
#    最終処理: push / PR / merge / 作業日報        (30m)
#
#  使い方:
#    chmod +x triple-loop-15h.sh
#    bash triple-loop-15h.sh              # デフォルト: 2サイクル（15H）
#    bash triple-loop-15h.sh --cycles 1   # 1サイクル（8H、軽量運用）
#═══════════════════════════════════════════════════════════════

set -euo pipefail

# ─── 設定 ───────────────────────────────────────────────────
PROJECT_DIR="$(pwd)"
LOG_DIR="${PROJECT_DIR}/.loop-logs"
DOCS_DIR="${PROJECT_DIR}/docs"
START_TIME=$(date +%s)

# タイミング設定（秒）
CD1_DURATION=600          # CD1: Monitor後 10分
CD2_DURATION=1200         # CD2: Build後 20分
CD3_DURATION=1800         # CD3: サイクル間 30分

# サイクル数（引数で変更可能）
MAX_CYCLES=2

# ─── 引数解析 ──────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --cycles)
      MAX_CYCLES="$2"
      shift 2
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --cycles N          サイクル数 (default: 2)"
      echo ""
      echo "サイクル別の所要時間:"
      echo "  1サイクル:  約 8時間（Monitor 30m + CD1 10m + Build 2h + CD2 20m + Verify 4h + Final 30m）"
      echo "  2サイクル:  約 15時間（Cycle1 7h + CD3 30m + Cycle2 7h + Final 30m）"
      echo ""
      echo "Triple Loop Architecture (Claude Code only):"
      echo "  Monitor(30m) → CD1(10m) → Build(2h) → CD2(20m) → Verify(4h)"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

mkdir -p "$LOG_DIR" "$DOCS_DIR"

# ─── ユーティリティ関数 ────────────────────────────────────
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_DIR/orchestrator.log"
}

elapsed() {
  echo $(( $(date +%s) - START_TIME ))
}

elapsed_fmt() {
  local e=$(elapsed)
  printf "%dh%02dm" $(( e / 3600 )) $(( (e % 3600) / 60 ))
}

cooldown() {
  local duration=$1
  local label=$2
  log "⏸  ${label} クールダウン開始（$(( duration / 60 ))分）"
  sleep $duration
  log "▶  ${label} クールダウン完了"
}

check_command() {
  if ! command -v "$1" &> /dev/null; then
    log "⚠️  警告: $1 が見つかりません。"
    return 1
  fi
  return 0
}

# ─── 事前チェック ──────────────────────────────────────────
check_command claude || { log "❌ claude コマンドが必要です"; exit 1; }

# Git リポジトリチェック
if [ ! -d .git ]; then
  log "❌ エラー: Git リポジトリではありません。git init を実行してください。"
  exit 1
fi

# ─── Monitor（Claude Code — 30分）─────────────────────────
run_monitor() {
  local cycle=$1
  log "═══ 🔍 Monitor 開始（Cycle ${cycle}）═══"

  # 前回の Verify 結果があれば読み込み指示に含める
  local verify_note=""
  if [ -f ".loop-verify-report.md" ]; then
    verify_note="
7. .loop-verify-report.md を読み込み、前回の Verify 検証結果を確認
   - Critical 指摘があれば次の Build で最優先対応すべきタスクとして推奨"
  fi

  claude --dangerously-skip-permissions \
    -p "あなたは Claude Code Autonomous Development System の Monitor Layer として動作してください。

以下を実行し、結果を .loop-monitor-report.md に出力してください:
1. git status と git log --oneline -10 を実行
2. テストを実行して結果サマリーを取得（npm test / pytest / go test など、プロジェクトに応じて選択）
3. lint / typecheck のエラー件数を取得
4. grep -rn 'TODO\|FIXME' src/ で未解決タスクを数える
5. TASKS.md を読み込み、完了/未完了の件数を集計
6. 前回の .loop-monitor-report.md があれば比較して差分を検出${verify_note}

異常検知基準（該当時は .loop-alert.md も出力）:
- テスト失敗数が前回より 3 件以上増加
- lint エラーが前回より 10 件以上増加
- 型エラーが新たに発生
- セキュリティ脆弱性が検出

コード変更は一切行わないこと。読み取り専用。

出力形式:
# Monitor Report — $(date '+%Y-%m-%d %H:%M') (Cycle ${cycle})
## プロジェクト状態
## 品質メトリクス
## タスク進捗
## 異常検知
## Build Loop への推奨事項" \
    --max-turns 20 \
    2>&1 | tee "$LOG_DIR/monitor-c${cycle}-$(date +%H%M).log"

  log "═══ 🔍 Monitor 完了（Cycle ${cycle}）═══"
}

# ─── Build（Claude Code — 2時間、5段階開発ステップ）───────
run_build() {
  local cycle=$1
  log "═══ 🔨 Build 開始（Cycle ${cycle}）═══"

  claude --dangerously-skip-permissions \
    -p "あなたは Claude Code Autonomous Development System の Build Layer として動作してください。
全操作を自動承認で続行。人間の確認待ちなし。

事前読み込み:
1. .loop-monitor-report.md を読み込み現状を把握
2. .loop-alert.md があれば最優先で対応
3. .loop-verify-report.md があれば前回の Verify 指摘を確認し対応
4. TASKS.md から優先度順にタスクを選択

5段階開発ステップを実行:

Step 1: 設計・計画（〜20分）
- TASKS.md からタスク選択
- Agent Teams Discussion（全8 Agent の発言を出力）
- 設計方針・実装計画を決定
→ commit: design: [タスク名] の設計方針決定

Step 2: 基盤実装（〜30分）
- データモデル / スキーマ / インターフェース定義
- API エンドポイント / ルーティング基盤
→ commit: feat: [タスク名] の基盤構造を実装

Step 3: コア機能実装（〜40分）
- ビジネスロジック / コアアルゴリズム
- UI コンポーネント / フロントエンド
→ commit: feat: [タスク名] のコア機能を実装

Step 4: 結合・統合（〜20分）
- モジュール間の結合 / インポート整理
- 型チェック・コンパイル通過確認
→ commit: feat: [タスク名] の結合・統合完了

Step 5: 単体テスト・品質確認（〜10分）
- 基本テスト作成・実行（主要パスのみ）
- lint / format 実行・修正
- 実装サマリーを .loop-build-handoff.md に記録
→ commit: test: [タスク名] の基本テスト追加

注意事項:
- 各 Step 完了ごとに main へ直接 commit
- 1タスク完走を優先（中途半端に複数タスクに着手しない）
- 2時間内で1タスク完了後に時間があれば次タスクに着手可
- 完了時に .loop-build-handoff.md を出力（Cycle: ${cycle}、完了タスク・コミット一覧・変更ファイル・テスト結果・既知リスク）" \
    --max-turns 50 \
    2>&1 | tee "$LOG_DIR/build-c${cycle}-$(date +%H%M).log"

  log "═══ 🔨 Build 完了（Cycle ${cycle}）═══"
}

# ─── Verify（Claude Code — 4時間、レビュー・テスト・デバッグ修正）──
run_verify() {
  local cycle=$1
  log "═══ 🧪 Verify 開始（Cycle ${cycle}）═══"

  claude --dangerously-skip-permissions \
    -p "あなたは Claude Code Autonomous Development System の Verify Layer として動作してください。
Build Loop の成果物を徹底的に検証する。問題発見時は修正して main に commit する。

事前読み込み:
- .loop-build-handoff.md を読み込み、Build Loop の成果物を把握する

4フェーズで実行:

Phase A: コードレビュー（〜60分）
- Build の全コミットを git diff でレビュー
- バグ・ロジックエラーのチェック
- セキュリティ脆弱性のチェック
- パフォーマンス問題のチェック
- コーディング規約準拠のチェック
- エラーハンドリングの網羅性
- レビュー指摘事項を一覧化

Phase B: テスト検証（〜90分）
- 既存テスト全件実行
- テストカバレッジ計測（目標: 80%）
- 不足テストの追加（正常系・異常系・エッジケース・境界値）
- 統合テスト / E2E テスト実行

Phase C: デバッグ修正（〜60分、失敗テストがある場合のみ）
- 失敗テストの原因分析
- バグ修正コード生成
- 修正後のテスト再実行
- CI 修復 AI（最大 15 回試行）
→ commit: fix: [バグ内容] を修正
→ commit: test: [テスト名] を追加・修正

Phase D: 品質レポート出力（〜30分）
- .loop-verify-report.md に検証結果を出力
- 発見した新規タスクを TASKS.md に追加
- 品質知見を AGENTS.md に記録

出力形式:
# Verify Report — $(date '+%Y-%m-%d %H:%M') (Cycle ${cycle})
## レビューサマリー
## テスト結果
## デバッグ修正
## セキュリティ監査
## 品質スコア
## Verify で発見した新規タスク" \
    --max-turns 80 \
    2>&1 | tee "$LOG_DIR/verify-c${cycle}-$(date +%H%M).log"

  log "═══ 🧪 Verify 完了（Cycle ${cycle}）═══"
}

# ─── 最終処理（Claude Code — 30分）──────────────────────────
run_final() {
  log "═══ 🏁 最終処理開始 ═══"

  local today=$(date '+%Y-%m-%d')
  local report_file="${DOCS_DIR}/${today}_自律開発作業報告.md"
  local cycle_label="${MAX_CYCLES}サイクル"

  claude --dangerously-skip-permissions \
    -p "自律開発セッション（Triple Loop 15H ${cycle_label}）が完了しました。以下を順番に実行してください:

1. git push origin main（全 commit を一括プッシュ）
2. Pull Request を作成（タイトル: 'feat: ${today} 15H自律開発セッション成果（${cycle_label}）'）
3. テスト全件 Pass を確認し PR をマージ
4. 作業日報を ${report_file} に出力:
   - ファイル形式: .md（Markdown）/ ファイル内容: 日本語
   - 内容: 実装詳細・品質レポート・次回への申し送り
   - 注記: このセッションは Claude Code Triple Loop 15H（${cycle_label}）で実行
   - 各サイクルの Monitor / Build / Verify 結果を含める

以下のファイルを参照:
- AGENTS.md
- .loop-monitor-report.md
- .loop-build-handoff.md
- .loop-verify-report.md
- git log --oneline

5. 完了後 LOOP_COMPLETE を出力" \
    --max-turns 30 \
    2>&1 | tee "$LOG_DIR/final-$(date +%H%M).log"

  log "═══ 🏁 最終処理完了 ═══"
}

# ═══════════════════════════════════════════════════════════════
#  メインループ
# ═══════════════════════════════════════════════════════════════

# 所要時間計算（秒）
# 1サイクル = Monitor(30m) + CD1(10m) + Build(2h) + CD2(20m) + Verify(4h) = 7h = 25200秒
CYCLE_DURATION=$(( 30*60 + CD1_DURATION + 120*60 + CD2_DURATION + 240*60 ))
FINAL_DURATION=$(( 30*60 ))

if [ "$MAX_CYCLES" -gt 1 ]; then
  # 複数サイクル: サイクル間にCD3あり
  TOTAL_ESTIMATE=$(( CYCLE_DURATION * MAX_CYCLES + CD3_DURATION * (MAX_CYCLES - 1) + FINAL_DURATION ))
else
  TOTAL_ESTIMATE=$(( CYCLE_DURATION + FINAL_DURATION ))
fi

log ""
log "╔══════════════════════════════════════════════════════════════╗"
log "║  🔄 Triple Loop 15H Orchestrator — Starting                 ║"
log "║  Claude Code Only — Full Quality (Monitor+Build+Verify)     ║"
log "╠══════════════════════════════════════════════════════════════╣"
log "║  Cycles     : ${MAX_CYCLES}                                           ║"
log "║  Estimate   : $(( TOTAL_ESTIMATE / 3600 ))h$(( (TOTAL_ESTIMATE % 3600) / 60 ))m                                        ║"
log "║  Per Cycle  : Monitor(30m) → CD1(10m) → Build(2h)          ║"
log "║               → CD2(20m) → Verify(4h) = 7h                 ║"
log "║  Start      : $(date '+%Y-%m-%d %H:%M:%S')                   ║"
log "╚══════════════════════════════════════════════════════════════╝"
log ""

for cycle_num in $(seq 1 $MAX_CYCLES); do
  log ""
  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  log "  Cycle ${cycle_num} / ${MAX_CYCLES} 開始 | 経過: $(elapsed_fmt)"
  log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # ── Monitor (30分) ──
  run_monitor "$cycle_num"

  # ── CD1 (10分) ──
  cooldown $CD1_DURATION "CD1(10分/Monitor→Build)"

  # ── Build (2時間) ──
  run_build "$cycle_num"

  # ── CD2 (20分) ──
  cooldown $CD2_DURATION "CD2(20分/Build→Verify)"

  # ── Verify (4時間) ──
  run_verify "$cycle_num"

  # サイクル間クールダウン CD3（最終サイクル以外）
  if [ "$cycle_num" -lt "$MAX_CYCLES" ]; then
    cooldown $CD3_DURATION "CD3(30分/サイクル間)"
  fi

  log ""
  log "  Cycle ${cycle_num} 完了 | 経過: $(elapsed_fmt)"
done

# ── 最終処理 (30分) ──
log ""
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
log "  🏁 最終処理 | 経過: $(elapsed_fmt)"
log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

run_final

log ""
log "╔══════════════════════════════════════════════════════════════╗"
log "║  🛑 Triple Loop 15H Orchestrator — Complete                  ║"
log "║  Cycles Completed : ${MAX_CYCLES}                                     ║"
log "║  Total Duration   : $(elapsed_fmt)                              ║"
log "║  End              : $(date '+%Y-%m-%d %H:%M:%S')             ║"
log "╚══════════════════════════════════════════════════════════════╝"
