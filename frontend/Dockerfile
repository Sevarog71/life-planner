FROM node:18-alpine

WORKDIR /app

# package.jsonをコピーして依存関係をインストール
COPY package.json package-lock.json ./
RUN npm ci --quiet

# アプリケーションコードをコピー
COPY . .

EXPOSE 5173

CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
