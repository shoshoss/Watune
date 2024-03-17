FROM node:20

# 言語環境をUTF-8、タイムゾーンを日本（東京）に設定
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

WORKDIR /usr/src/app

# プロジェクトの依存関係をインストール
COPY package.json .
COPY package-lock.json .
RUN npm install

# アプリケーションのソースコードをコピー
COPY . .
