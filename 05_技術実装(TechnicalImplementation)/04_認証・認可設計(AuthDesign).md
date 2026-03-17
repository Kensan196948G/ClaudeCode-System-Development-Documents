# 04 認証・認可設計（Authentication and Authorization Design）

---

## 概要

アプリケーションの認証・認可機構を Claude Code が設計・実装するためのプロンプトです。

---

## Claude Code 起動コマンド

```
以下の認証・認可システムを設計・実装してください。

【要件】
- 認証方式: [JWT / Session / OAuth2 / OIDC]
- 認可モデル: [RBAC / ABAC / ACL]
- 対象: [Web API / SPA / モバイルアプリ]

【セキュリティ要件】
- パスワードハッシュ化（bcrypt / Argon2）
- トークン有効期限設定
- リフレッシュトークン対応
- ブルートフォース対策
- セッション管理

テストコードも含めて実装してください。
```

---

## 認証方式の比較

| 方式 | 用途 | メリット | デメリット |
|------|------|---------|----------|
| JWT | API認証 | ステートレス・スケーラブル | トークン無効化が困難 |
| Session | Webアプリ | サーバー側で無効化可能 | スケールアウト時に共有ストアが必要 |
| OAuth2 | 外部サービス連携 | 標準化・セキュア | 複雑な実装 |
| OIDC | SSO | OAuth2 + ID情報 | さらに複雑 |

---

## JWT 実装パターン

### トークン構造

```
Header:  { "alg": "RS256", "typ": "JWT" }
Payload: {
  "sub": "user-id",
  "email": "user@example.com",
  "roles": ["user"],
  "iat": 1700000000,
  "exp": 1700003600  // 1時間後
}
Signature: RS256(base64(header) + "." + base64(payload), privateKey)
```

### リフレッシュトークン戦略

```
アクセストークン: 有効期限 15分（短期）
リフレッシュトークン: 有効期限 7日（長期）

フロー:
1. ログイン → アクセストークン + リフレッシュトークン発行
2. APIリクエスト → アクセストークンを Authorization ヘッダに付与
3. アクセストークン期限切れ → リフレッシュトークンで再発行
4. ログアウト → リフレッシュトークンを無効化（DBに記録）
```

---

## RBAC（ロールベースアクセス制御）

```yaml
ロール定義:
  admin:
    - users:read
    - users:write
    - users:delete
    - settings:write
  manager:
    - users:read
    - users:write
    - reports:read
  user:
    - profile:read
    - profile:write
```

### ミドルウェア実装例（Node.js）

```typescript
// src/middleware/authorize.ts
export const authorize = (...requiredPermissions: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const userPermissions = req.user?.permissions ?? [];
    const hasPermission = requiredPermissions.every(p =>
      userPermissions.includes(p)
    );
    if (!hasPermission) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
};

// ルートへの適用
router.delete('/users/:id', authenticate, authorize('users:delete'), deleteUser);
```

---

## セキュリティチェックリスト

### 認証
- [ ] パスワードは bcrypt/Argon2 でハッシュ化
- [ ] 平文パスワードをログに出力していない
- [ ] ブルートフォース対策（レートリミット）
- [ ] アカウントロック機能
- [ ] 多要素認証（MFA）の対応

### トークン
- [ ] 適切な有効期限設定
- [ ] 安全な署名アルゴリズム（RS256推奨）
- [ ] トークンをURLパラメータに含めない
- [ ] HTTPS必須

### セッション
- [ ] セッションIDの再生成（ログイン後）
- [ ] セッション固定攻撃対策
- [ ] Secure / HttpOnly / SameSite Cookie 属性

---

## 関連ドキュメント

- [APIサーバー構築](./01_APIサーバー構築(APIServerBuild).md)
- [セキュリティ診断](../04_インフラ・DevOps(InfraDevOps)/02_セキュリティ診断(SecurityAudit).md)
