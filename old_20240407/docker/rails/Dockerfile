# Rubyのバージョンを指定
FROM ruby:3.3.0

# 必要なパッケージのインストール（PostgreSQLクライアント、libpq-dev）
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client libpq-dev && rm -rf /var/lib/apt/lists/*

# アプリケーションの作業ディレクトリを設定
WORKDIR /backend

# GemfileとGemfile.lockをコピーして依存関係をインストール
COPY Gemfile Gemfile.lock ./
RUN gem install bundler -v 2.5.6 && bundle _2.5.6_ install

# アプリケーションのコードをコピー
COPY . .
