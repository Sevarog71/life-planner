# ライフプラン作成・管理ツール 開発計画

## プロジェクト概要
- **目的**: 定期的にライフプランを作成・見直しできる管理ツール
- **技術スタック**: React (フロントエンド) + Ruby on Rails (バックエンド) + PostgreSQL
- **環境**: WSL + Docker Desktop + GitHub
- **アプローチ**: プロトタイプから始めて段階的に機能拡張

## 主要機能
1. ライフイベント管理（結婚、出産、住宅購入、退職など）
2. 収支管理・予算計画（月次・年次の収入と支出）
3. 資産シミュレーション
4. グラフ・ビジュアライゼーション

## プロジェクト構成
**プロジェクトパス**: `/home/awkca/WorkSpace/life-planner`

```
WorkSpace/
└── life-planner/
    ├── docker-compose.yml          # Docker設定（Rails, React, PostgreSQL）
    ├── .env                        # 環境変数
    ├── .gitignore
    ├── backend/                    # Rails APIアプリケーション
    │   ├── Dockerfile
    │   ├── Gemfile
    │   ├── app/
    │   │   ├── controllers/
    │   │   ├── models/
    │   │   └── serializers/
    │   ├── config/
    │   │   └── database.yml
    │   └── db/
    │       └── migrate/
    ├── frontend/                   # Reactアプリケーション
    │   ├── Dockerfile
    │   ├── package.json
    │   ├── src/
    │   │   ├── components/
    │   │   ├── pages/
    │   │   ├── services/
    │   │   └── App.jsx
    │   └── public/
    └── README.md
```

## 実装フェーズ

### フェーズ1: 開発環境セットアップ
1. **プロジェクトディレクトリの作成**
   - `/home/awkca/WorkSpace` ディレクトリを作成
   - `/home/awkca/WorkSpace/life-planner` プロジェクトディレクトリを作成

2. **Docker環境の構築**
   - `docker-compose.yml` の作成（PostgreSQL, Rails, React の3サービス）
   - PostgreSQL コンテナ設定（データ永続化）
   - Rails API コンテナ設定（Ruby 3.x）
   - React開発サーバーコンテナ設定（Node.js 20.x）

3. **Rails バックエンドの初期化**
   - Rails API モード プロジェクト生成
   - PostgreSQL アダプタ設定
   - CORS 設定（React からのアクセス許可）
   - 基本的なGemfile構成（rails, pg, rack-cors, etc.）

4. **React フロントエンドの初期化**
   - Vite + React プロジェクト生成
   - 必要なライブラリのインストール
     - axios（API通信）
     - react-router-dom（ルーティング）
     - recharts または chart.js（グラフ表示）
     - tailwindcss または Material-UI（スタイリング）

5. **Git リポジトリの初期化**
   - `.gitignore` の設定
   - 初回コミット
   - GitHub リポジトリへのプッシュ（オプション）

### フェーズ2: データベース設計とモデル作成

#### データモデル
1. **Users** (将来的な拡張用、現在は単一ユーザー)
   - id, name, email

2. **LifeEvents** (ライフイベント)
   - id, title, event_type, planned_date, estimated_cost, actual_cost, description
   - event_type: 結婚、出産、住宅購入、子供の進学、退職など

3. **AnnualBudgets** (年次予算) - **採用決定**
   - id, year, annual_income, annual_expense, notes
   - 1年に1レコード、シンプルで入力しやすい
   - 将来的にカテゴリ別への拡張も可能

4. **Assets** (資産) - 将来的
   - id, asset_type, initial_amount, expected_return_rate
   - asset_type: 貯蓄、投資、不動産など

#### マイグレーション作成
```bash
# ライフイベント
docker-compose exec backend rails g model LifeEvent event_type:string name:string scheduled_date:date estimated_cost:decimal notes:text

# 年次予算
docker-compose exec backend rails g model AnnualBudget year:integer annual_income:decimal annual_expense:decimal notes:text

# マイグレーション実行
docker-compose exec backend rails db:migrate
```

### フェーズ3: Rails API エンドポイント実装

#### APIエンドポイント設計
```
# ライフイベントAPI
GET    /api/v1/life_events          # イベント一覧
POST   /api/v1/life_events          # イベント作成
GET    /api/v1/life_events/:id      # イベント詳細
PUT    /api/v1/life_events/:id      # イベント更新
DELETE /api/v1/life_events/:id      # イベント削除

# 年次予算API
GET    /api/v1/annual_budgets       # 年次予算一覧（全年度）
POST   /api/v1/annual_budgets       # 年次予算作成
GET    /api/v1/annual_budgets/:id   # 年次予算詳細（特定年度）
PUT    /api/v1/annual_budgets/:id   # 年次予算更新
DELETE /api/v1/annual_budgets/:id   # 年次予算削除

# シミュレーションAPI
GET    /api/v1/simulation           # シミュレーション計算
  - クエリパラメータ: start_year, end_year
  - レスポンス: 年次ごとの収支、資産推移データ
```

#### コントローラとシリアライザ
- 各リソースのコントローラ作成
- JSON シリアライザ（ActiveModel::Serializers または jbuilder）
- バリデーションとエラーハンドリング

#### シミュレーションロジック
- `SimulationService` クラス作成
- 年次ごとの収支計算
- 資産推移の計算
- イベント発生時の影響を反映

### フェーズ4: React フロントエンド実装

#### ページ構成
1. **ダッシュボード** (`/`)
   - 全体サマリー表示
   - 資産推移グラフ
   - 直近のライフイベント

2. **ライフイベント管理** (`/events`)
   - イベント一覧
   - イベント追加/編集フォーム
   - タイムライン表示

3. **収支管理** (`/budget`)
   - 収入項目一覧
   - 支出項目一覧
   - カテゴリ別集計

4. **シミュレーション** (`/simulation`)
   - 期間設定
   - 資産推移グラフ
   - 年次収支表

#### コンポーネント設計
```
src/
├── components/
│   ├── common/
│   │   ├── Header.jsx
│   │   ├── Navigation.jsx
│   │   └── Button.jsx
│   ├── events/
│   │   ├── EventList.jsx
│   │   ├── EventForm.jsx
│   │   └── EventTimeline.jsx
│   ├── budget/
│   │   ├── IncomeList.jsx
│   │   ├── ExpenseList.jsx
│   │   └── BudgetForm.jsx
│   └── simulation/
│       ├── SimulationChart.jsx
│       └── SimulationTable.jsx
├── pages/
│   ├── Dashboard.jsx
│   ├── Events.jsx
│   ├── Budget.jsx
│   └── Simulation.jsx
├── services/
│   └── api.js              # API通信ロジック
└── App.jsx
```

#### API通信設定
- axios インスタンス設定（ベースURL: http://localhost:3000/api）
- エラーハンドリング
- ローディング状態管理

### フェーズ5: グラフ・ビジュアライゼーション実装

#### グラフの種類
1. **資産推移グラフ** (折れ線グラフ)
   - X軸: 年
   - Y軸: 資産額

2. **年次収支グラフ** (棒グラフ)
   - 収入と支出を並べて表示

3. **カテゴリ別支出** (円グラフ)
   - 支出カテゴリの割合

4. **ライフイベントタイムライン**
   - イベントを時系列で視覚化

#### 使用ライブラリ
- recharts または Chart.js
- 日付表示: date-fns

### フェーズ6: テストとブラッシュアップ

1. **バックエンドテスト**
   - RSpec でモデル・コントローラのテスト
   - シミュレーションロジックのテスト

2. **フロントエンドテスト**
   - Vitest でコンポーネントテスト（オプション）

3. **E2Eテスト**
   - 基本的なユーザーフロー確認

4. **UI/UX改善**
   - レスポンシブ対応
   - エラーメッセージの改善
   - ローディング表示

## 初期セットアップ手順（実装時）

### 1. プロジェクト作成
```bash
# WorkSpaceディレクトリの作成
mkdir -p /home/awkca/WorkSpace
cd /home/awkca/WorkSpace

# プロジェクトディレクトリの作成
mkdir life-planner
cd life-planner

# Gitリポジトリ初期化
git init
```

### 2. Docker Compose 設定作成
- PostgreSQL サービス（ポート5432）
- Rails API サービス（ポート3000）
- React サービス（ポート5173）
- ボリューム設定（データ永続化、ホットリロード）

### 3. コンテナ起動とアプリ初期化
```bash
cd /home/awkca/WorkSpace/life-planner

# DB起動
docker-compose up -d db

# Rails APIアプリ初期化
docker-compose run backend rails new . --api --database=postgresql

# Reactアプリ初期化
docker-compose run frontend npm create vite@latest . -- --template react
```

### 4. 設定ファイル調整
- `backend/config/database.yml` (PostgreSQL接続設定)
- `backend/config/initializers/cors.rb` (CORS設定)
- `frontend/vite.config.js` (プロキシ設定)

### 5. データベース作成
```bash
docker-compose run backend rails db:create
docker-compose run backend rails db:migrate
```

### 6. 動作確認
- http://localhost:3000 (Rails API)
- http://localhost:5173 (React アプリ)

## 技術的な考慮事項

### セキュリティ
- 現時点では認証なし（個人利用前提）
- 将来的に複数ユーザー対応する場合は devise + JWT 検討

### パフォーマンス
- シミュレーション計算の最適化
- フロントエンドでのキャッシング（React Query など）

### データ永続化
- Docker ボリュームでPostgreSQLデータを永続化
- バックアップ機能の検討（将来）

## 実装の開始手順（最初に実行するコマンド）

```bash
# 1. WorkSpaceとプロジェクトディレクトリの作成
mkdir -p /home/awkca/WorkSpace/life-planner
cd /home/awkca/WorkSpace/life-planner
mkdir -p backend frontend docs

# 2. Gitリポジトリ初期化
git init

# 3. 環境変数ファイル作成
cat > .env << 'EOF'
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=life_planner_development
RAILS_ENV=development
RAILS_MAX_THREADS=5
VITE_API_URL=http://localhost:3000
NODE_ENV=development
EOF

# 4. docker-compose.yml の作成（以下の内容をファイルに記述）
# 5. backend/Dockerfile の作成
# 6. frontend/Dockerfile の作成
# 7. Docker環境の起動とアプリ初期化
```

## 重要ファイルの作成順序

### 必須ファイル（Docker環境構築）
1. `/home/awkca/WorkSpace/life-planner/docker-compose.yml` - 全サービスの定義
2. `/home/awkca/WorkSpace/life-planner/backend/Dockerfile` - Rails環境
3. `/home/awkca/WorkSpace/life-planner/frontend/Dockerfile` - React環境
4. `/home/awkca/WorkSpace/life-planner/.env` - 環境変数

### Rails初期化後に編集するファイル
5. `/home/awkca/WorkSpace/life-planner/backend/config/database.yml` - DB接続設定
6. `/home/awkca/WorkSpace/life-planner/backend/config/initializers/cors.rb` - CORS設定
7. `/home/awkca/WorkSpace/life-planner/backend/Gemfile` - rack-cors, blueprinter追加

### React初期化後に編集するファイル
8. `/home/awkca/WorkSpace/life-planner/frontend/vite.config.ts` - 開発サーバー設定
9. `/home/awkca/WorkSpace/life-planner/frontend/package.json` - dev scriptの編集

## MVP実装の優先順位

### Phase 1: 環境構築（推定1-2日）
- Docker環境セットアップ
- Rails API初期化
- React初期化
- CORS設定とAPI疎通確認

### Phase 2: ライフイベント機能（推定2-3日）
**データモデル**:
```ruby
# life_events テーブル
- event_type: string (marriage, birth, house_purchase, retirement等)
- name: string
- scheduled_date: date
- estimated_cost: decimal
- notes: text
```

**API**: `/api/v1/life_events` (CRUD)
**フロントエンド**: イベント一覧、作成・編集フォーム

### Phase 3: 収支管理（推定2-3日）
**データモデル**（年単位の入力管理 - シンプル版採用）:
```ruby
# annual_budgets テーブル
- year: integer (例: 2024, 2025)
- annual_income: decimal (年間収入)
- annual_expense: decimal (年間支出)
- notes: text (メモ)
- created_at, updated_at
```

**特徴**:
- 1年に1レコード、シンプルで入力しやすい
- 年度ごとの収支バランスを素早く把握
- 将来的にカテゴリ別への拡張も可能

**API**: `/api/v1/annual_budgets` (CRUD)
**フロントエンド**: 年単位の収入・支出入力フォーム、年次推移グラフ

### Phase 4: シミュレーション機能（推定3-4日）
**ロジック**:
- 年次ごとの収支計算
- 資産推移の計算
- ライフイベント発生時の影響を反映

**API**: `GET /api/v1/simulation?start_year=2024&end_year=2050`
**フロントエンド**:
- Recharts導入
- 資産推移グラフ（折れ線グラフ）
- キャッシュフロー可視化（棒グラフ）

### Phase 5: UI/UX改善（推定2-3日）
- レスポンシブデザイン
- ローディング状態表示
- エラーハンドリング改善
- バリデーションメッセージ

## 技術的なポイント

### Docker構成
- **PostgreSQL**: ポート5432、データ永続化（volumeで管理）
- **Rails API**: ポート3000、API modeで軽量化
- **React + Vite**: ポート5173、WSL2対応のポーリング設定

### WSL2対応設定
```yaml
# docker-compose.yml frontendサービス
environment:
  CHOKIDAR_USEPOLLING: true  # ファイル監視
  WATCHPACK_POLLING: true
```

### CORS設定
```ruby
# backend/config/initializers/cors.rb
origins 'localhost:5173', '127.0.0.1:5173'
```

### API通信
```typescript
// frontend/src/services/api.ts
const apiClient = axios.create({
  baseURL: 'http://localhost:3000/api/v1',
  headers: { 'Content-Type': 'application/json' },
});
```

## よく使うDockerコマンド

```bash
# 全サービス起動
docker-compose up -d

# ログ確認
docker-compose logs -f backend

# コンテナに入る
docker-compose exec backend bash
docker-compose exec frontend sh

# DB操作
docker-compose exec backend rails db:create
docker-compose exec backend rails db:migrate
docker-compose exec backend rails console

# マイグレーション作成
docker-compose exec backend rails g model ModelName field:type

# フロントエンドパッケージ追加
docker-compose exec frontend npm install package-name

# 停止・削除
docker-compose down
docker-compose down -v  # ボリューム含めて削除（データ消去注意）
```

## トラブルシューティング

### Railsサーバーが起動しない
```bash
# server.pidを削除（docker-compose.ymlで自動対応済み）
docker-compose exec backend rm -f tmp/pids/server.pid
```

### CORSエラー
- `backend/config/initializers/cors.rb` でoriginsを確認
- Reactの開発サーバーURL（localhost:5173）が含まれているか確認

### DB接続エラー
```bash
# DBを再作成
docker-compose down -v
docker-compose up -d db
docker-compose exec backend rails db:create db:migrate
```

---

この計画は段階的に実装を進めるためのロードマップです。まずは最小限の機能（ライフイベント管理と簡単なシミュレーション）から始めて、徐々に機能を拡張していきます。

---

## 参考: 詳細な設定ファイルの内容

Plan agentによる詳細設計では以下のファイルの完全な内容が提供されています：

### 主要設定ファイル
1. **docker-compose.yml** - 3サービス（PostgreSQL, Rails, React）の完全な定義
   - DB healthcheck設定
   - Volume設定（postgres_data, bundle_cache等）
   - WSL2対応のポーリング設定
   - 環境変数の詳細

2. **backend/Dockerfile** - Ruby 3.2.2ベースの軽量イメージ
   - 必要最小限のパッケージインストール
   - Bundle設定とキャッシュ最適化

3. **frontend/Dockerfile** - Node 18 Alpineベースの軽量イメージ
   - npm ciによる依存関係インストール

4. **backend/config/database.yml** - Docker環境用DB接続設定
5. **backend/config/initializers/cors.rb** - CORS設定の完全な例
6. **frontend/vite.config.ts** - WSL2対応のファイル監視設定

### データモデル詳細
- LifeEvent、IncomeItem、ExpenseItem の完全なスキーマ定義
- バリデーションルールの例
- Blueprinter（JSONシリアライザ）の実装例

### API設計
- RESTful APIのエンドポイント一覧
- コントローラーの実装例
- エラーハンドリングパターン

### フロントエンド設計
- ディレクトリ構造の詳細
- TypeScript型定義の例
- カスタムフックの実装パターン
- API通信サービスの実装例

これらの詳細な内容は、実装時に必要に応じて参照してください。（Plan agent ID: a774163）
