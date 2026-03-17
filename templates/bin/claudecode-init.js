#!/usr/bin/env node
/**
 * claudecode-init — ClaudeCode .claude/ テンプレートセットアップスクリプト
 * 
 * 使い方:
 *   npx claudecode-init
 *   または
 *   node bin/claudecode-init.js
 */

const fs = require('fs');
const path = require('path');
const readline = require('readline');

const rl = readline.createInterface({ input: process.stdin, output: process.stdout });
const ask = (q) => new Promise(res => rl.question(q, res));

const TEMPLATE_DIR = path.join(__dirname, '..');
const TARGET_DIR = process.cwd();

async function main() {
  console.log('\n🤖 ClaudeCode プロジェクト初期化ツール\n');
  console.log(`対象ディレクトリ: ${TARGET_DIR}\n`);

  const claudeDir = path.join(TARGET_DIR, '.claude');
  if (fs.existsSync(claudeDir)) {
    const ans = await ask('.claude/ ディレクトリが既に存在します。上書きしますか？ [y/N]: ');
    if (ans.toLowerCase() !== 'y') {
      console.log('キャンセルしました。');
      rl.close();
      return;
    }
  }

  // プロジェクト情報の入力
  const projectName = await ask('プロジェクト名を入力してください: ');
  const language    = await ask('使用言語 (例: TypeScript, Python, Go): ');
  const framework   = await ask('フレームワーク (例: Express, FastAPI, Gin): ');
  const testTool    = await ask('テストツール (例: Jest, pytest, testing): ');

  rl.close();

  // .claude/ ディレクトリ構造を作成
  const dirs = [
    '.claude',
    '.claude/commands',
    '.claude/hooks',
    '.claude/mcp-configs',
  ];
  dirs.forEach(d => fs.mkdirSync(path.join(TARGET_DIR, d), { recursive: true }));

  // CLAUDE.md テンプレートをコピーして置換
  let claudeMd = fs.readFileSync(path.join(TEMPLATE_DIR, '.claude/CLAUDE.md'), 'utf8');
  claudeMd = claudeMd
    .replace(/\[PROJECT_NAME\]/g, projectName || 'My Project')
    .replace(/\[TypeScript \/ Python \/ Go など\]/g, language || 'TypeScript')
    .replace(/\[Express \/ FastAPI \/ Gin など\]/g, framework || 'Express')
    .replace(/\[Jest \/ pytest \/ testing など\]/g, testTool || 'Jest')
    .replace(/\[あなたのテストツール\]/g, testTool || 'Jest')
    .replace(/\[あなたの言語\]/g, language || 'TypeScript');
  fs.writeFileSync(path.join(TARGET_DIR, '.claude/CLAUDE.md'), claudeMd);

  // settings.json をコピー
  fs.copyFileSync(
    path.join(TEMPLATE_DIR, '.claude/settings.json'),
    path.join(TARGET_DIR, '.claude/settings.json')
  );

  // commands をコピー
  ['review.md', 'deploy.md'].forEach(f => {
    fs.copyFileSync(
      path.join(TEMPLATE_DIR, '.claude/commands', f),
      path.join(TARGET_DIR, '.claude/commands', f)
    );
  });

  // hooks をコピー
  ['post-write.sh', 'pre-commit.sh'].forEach(f => {
    const src = path.join(TEMPLATE_DIR, '.claude/hooks', f);
    const dst = path.join(TARGET_DIR, '.claude/hooks', f);
    fs.copyFileSync(src, dst);
    fs.chmodSync(dst, '755');
  });

  // MCP configs をコピー
  ['github.json', 'slack.json'].forEach(f => {
    fs.copyFileSync(
      path.join(TEMPLATE_DIR, '.claude/mcp-configs', f),
      path.join(TARGET_DIR, '.claude/mcp-configs', f)
    );
  });

  console.log('\n✅ .claude/ ディレクトリを作成しました:\n');
  console.log('  .claude/');
  console.log('  ├── CLAUDE.md          ← プロジェクト情報を入力済み');
  console.log('  ├── settings.json      ← 必要に応じて編集してください');
  console.log('  ├── commands/review.md');
  console.log('  ├── commands/deploy.md');
  console.log('  ├── hooks/post-write.sh');
  console.log('  ├── hooks/pre-commit.sh');
  console.log('  ├── mcp-configs/github.json');
  console.log('  └── mcp-configs/slack.json\n');
  console.log('次のステップ:');
  console.log('  1. .claude/CLAUDE.md を確認・編集');
  console.log('  2. .claude/settings.json でツール権限を調整');
  console.log('  3. claude を起動してTriple Loopを開始\n');
}

main().catch(err => {
  console.error('エラー:', err.message);
  process.exit(1);
});
