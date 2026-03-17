# 06 コンテナ化（Containerization）

---

## 概要

アプリケーションの Docker コンテナ化と Kubernetes 展開を  
Claude Code が自律的に設計・実装するためのプロンプトです。

---

## Claude Code 起動コマンド

```
以下のアプリケーションをコンテナ化してください。

【アプリケーション情報】
- 言語/ランタイム: [Node.js 20 / Python 3.11 など]
- フレームワーク: [Express / FastAPI など]
- 依存サービス: [PostgreSQL / Redis / S3 など]

【要件】
- マルチステージビルドでイメージサイズを最小化
- 非rootユーザーで実行
- ヘルスチェックエンドポイントの設定
- Kubernetes Deployment / Service / ConfigMap / Secret の生成
- Horizontal Pod Autoscaler の設定

セキュリティスキャン（Trivy）の GitHub Actions も含めてください。
```

---

## Dockerfile ベストプラクティス

### Node.js マルチステージビルド

```dockerfile
# ---- Build Stage ----
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# ---- Production Stage ----
FROM node:20-alpine AS production
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --chown=appuser:appgroup . .
USER appuser
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "src/server.js"]
```

### Python マルチステージビルド

```dockerfile
# ---- Build Stage ----
FROM python:3.11-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# ---- Production Stage ----
FROM python:3.11-slim AS production
RUN useradd -m -r appuser
WORKDIR /app
COPY --from=builder /root/.local /home/appuser/.local
COPY --chown=appuser:appuser . .
USER appuser
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8000/health || exit 1
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

---

## Kubernetes マニフェスト

### Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
        - name: myapp
          image: myapp:latest
          ports:
            - containerPort: 3000
          env:
            - name: DATABASE_URL
              valueFrom:
                secretKeyRef:
                  name: myapp-secret
                  key: database-url
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "512Mi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /health
              port: 3000
            initialDelaySeconds: 15
          readinessProbe:
            httpGet:
              path: /ready
              port: 3000
            initialDelaySeconds: 5
```

---

## セキュリティスキャン（Trivy）

```yaml
# .github/workflows/container-scan.yml
name: Container Security Scan
on:
  push:
    branches: [main, develop]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build image
        run: docker build -t myapp:${{ github.sha }} .
      - name: Run Trivy scan
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: myapp:${{ github.sha }}
          format: sarif
          output: trivy-results.sarif
          severity: CRITICAL,HIGH
      - name: Upload results
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: trivy-results.sarif
```

---

## 関連ドキュメント

- [CI/CD構築](./01_CI_CD構築(CICDSetup).md)
- [環境構築](./04_環境構築(EnvironmentSetup).md)
- [デプロイ戦略](./05_デプロイ戦略(DeploymentStrategy).md)
