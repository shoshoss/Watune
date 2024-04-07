# ベースイメージ
FROM node:20

# 言語環境とタイムゾーンの設定
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

# アプリケーションディレクトリを設定
WORKDIR /usr/src/app

# 依存関係ファイルをコピー
COPY package*.json ./

# 依存関係のインストール
RUN npm install

# アプリケーションのソースコードをコピー
COPY . .

# Next.jsのビルド
RUN npm run build

# ビルドされたアプリケーションの実行
CMD ["npm", "start"]
