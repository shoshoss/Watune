# React フロントエンド用の Dockerfile
FROM node:20

# 作業ディレクトリの作成と設定
RUN mkdir /frontend
WORKDIR /frontend

# 依存関係のインストール
COPY package.json package-lock.json /app/
RUN yarn install

# アプリケーションのコードをコピー
COPY . /frontend
