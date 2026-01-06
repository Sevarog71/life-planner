# ライフプラン作成・管理ツール

定期的にライフプランを作成・見直しできる管理ツールです。

## 技術スタック

- **フロントエンド**: React + Vite
- **バックエンド**: Ruby on Rails (API mode)
- **データベース**: PostgreSQL
- **開発環境**: Docker + Docker Compose

## 主要機能

1. **ライフイベント管理** - 結婚、出産、住宅購入、退職などの重要なイベントを記録
2. **年次収支管理** - 年単位での収入と支出を管理
3. **資産シミュレーション** - 将来の資産推移をシミュレーション
4. **グラフ・ビジュアライゼーション** - データを視覚的に表示

## セットアップ手順

### 前提条件

- Docker Desktop がインストールされていること
- WSL2 (Windowsの場合)

### 1. プロジェクトのクローン

```bash
cd /home/awkca/WorkSpace
cd life-planner
```

### 2. Railsアプリケーションの初期化

```bash
# Railsプロジェクトを生成
docker run --rm -v "$PWD/backend:/app" -w /app ruby:3.2.2-slim \
  bash -c "apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs git && \
  gem install rails -v 7.1.0 && \
  rails new . --api --database=postgresql --skip-test --skip-bundle --force"
```

### 3. Reactアプリケーションの初期化

```bash
# Vite + Reactプロジェクトを生成
docker run --rm -v "$PWD/frontend:/app" -w /app node:18-alpine \
  sh -c "npm create vite@latest . -- --template react --force"
```

### 4. 設定ファイルの調整

#### backend/config/database.yml
Docker環境用にデータベース接続設定を編集してください。

#### backend/config/initializers/cors.rb
React開発サーバーからのアクセスを許可するCORS設定を追加してください。

#### frontend/vite.config.js
WSL2対応のファイル監視設定を追加してください。

### 5. Dockerコンテナの起動

```bash
# コンテナをビルドして起動
docker-compose build
docker-compose up -d

# データベースの作成とマイグレーション
docker-compose exec backend rails db:create
docker-compose exec backend rails db:migrate
```

### 6. アクセス

- **フロントエンド**: http://localhost:5173
- **バックエンドAPI**: http://localhost:3000
- **データベース**: localhost:5432

## 開発コマンド

```bash
# ログ確認
docker-compose logs -f backend
docker-compose logs -f frontend

# コンテナに入る
docker-compose exec backend bash
docker-compose exec frontend sh

# データベース操作
docker-compose exec backend rails db:migrate
docker-compose exec backend rails console

# 停止
docker-compose down

# 完全にリセット（データも削除）
docker-compose down -v
```

## プロジェクト構造

```
life-planner/
├── backend/          # Rails APIアプリケーション
├── frontend/         # Reactアプリケーション
├── docs/             # ドキュメント
├── docker-compose.yml
├── .env              # 環境変数
└── README.md
```

## ライセンス

Private use only
