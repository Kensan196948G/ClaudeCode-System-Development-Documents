# 02 コーディング規約（Coding Standards）

---

## 概要

チーム全体で一貫したコードを書くためのコーディング規約と、  
Claude Code による規約チェック・適用自動化のプロンプトです。

---

## Claude Code 起動コマンド

```
以下のプロジェクトのコーディング規約を確認・適用してください。

【対象】
[ファイルパス or PR番号]

【チェック項目】
1. 命名規則（変数・関数・クラス・ファイル）
2. コードフォーマット（インデント・空白・改行）
3. コメント・ドキュメンテーション規約
4. エラーハンドリング規約
5. インポート・依存関係の整理
6. Gitコミットメッセージ規約

違反箇所を列挙し、自動修正可能なものは修正してください。
```

---

## 言語別規約

### TypeScript / JavaScript

```typescript
// ✅ 良い例
const MAX_RETRY_COUNT = 3;  // 定数: UPPER_SNAKE_CASE

class UserService {  // クラス: PascalCase
  private readonly userRepository: UserRepository;

  async findById(userId: string): Promise<User | null> {  // メソッド: camelCase
    if (!userId) {
      throw new InvalidArgumentError('userId is required');
    }
    return this.userRepository.findById(userId);
  }
}

// ❌ 悪い例
const maxretrycount = 3;  // 定数なのに lowercase
class userService {}      // クラスなのに lowercase
async FindById() {}       // メソッドなのに PascalCase
```

### Python

```python
# ✅ 良い例
MAX_RETRY_COUNT = 3  # 定数: UPPER_SNAKE_CASE

class UserService:  # クラス: PascalCase
    def find_by_id(self, user_id: str) -> User | None:  # 関数: snake_case
        if not user_id:
            raise ValueError("user_id is required")
        return self._repository.find_by_id(user_id)

# ❌ 悪い例
maxretrycount = 3
class userservice:
def findById(self, userId):
```

---

## コミットメッセージ規約（Conventional Commits）

```
<type>(<scope>): <subject>

[optional body]

[optional footer]
```

### タイプ一覧

| タイプ | 用途 | 例 |
|--------|------|-----|
| `feat` | 新機能 | `feat(auth): JWTリフレッシュトークン対応` |
| `fix` | バグ修正 | `fix(api): ユーザー一覧のページネーション修正` |
| `docs` | ドキュメント | `docs: README にセットアップ手順を追加` |
| `style` | フォーマット | `style: ESLint 警告を修正` |
| `refactor` | リファクタリング | `refactor(user): サービス層を分離` |
| `test` | テスト | `test(auth): ログイン失敗ケースのテスト追加` |
| `chore` | ビルド・設定 | `chore: Node.js 20 にアップグレード` |
| `perf` | パフォーマンス | `perf(db): N+1 クエリを解消` |

---

## ESLint 設定例（TypeScript）

```json
{
  "extends": [
    "eslint:recommended",
    "@typescript-eslint/recommended",
    "prettier"
  ],
  "rules": {
    "no-console": "warn",
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/explicit-function-return-type": "warn",
    "@typescript-eslint/no-unused-vars": "error",
    "prefer-const": "error"
  }
}
```

---

## PR レビュー規約

### レビュアーのルール
- 24時間以内にレスポンス
- 建設的なフィードバック（問題 + 改善案をセットで）
- LGTM は最低2名

### 著者のルール
- PR サイズは 400行以下（大きい場合は分割）
- セルフレビューを先に実施
- CI が全通過してからレビュー依頼

---

## 関連ドキュメント

- [ドキュメント生成](./01_ドキュメント生成(DocGeneration).md)
- [コードレビュー](../03_開発シナリオ(DevelopmentScenarios)/03_コードレビュー(CodeReview).md)
- [テスト自動化](../03_開発シナリオ(DevelopmentScenarios)/05_テスト自動化(TestAutomation).md)
