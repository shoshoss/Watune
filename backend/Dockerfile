# Rubyのバージョンを指定して基本イメージを選択
FROM ruby:3.3.0-slim

# 必要なパッケージのインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev postgresql-client curl && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# /backend を作業ディレクトリとして使用
WORKDIR /backend

# GemfileとGemfile.lockをコピーして、依存関係をインストール
COPY Gemfile Gemfile.lock ./
RUN bundle install

# アプリケーションのコードをコピー
COPY . .

# データベース設定ファイルのコピー（適切なパスに修正が必要）
COPY ../docker/postgres/database.yml /backend/config/database.yml

# セキュリティ強化のため、非rootユーザーでアプリケーションを実行
RUN useradd -m -s /bin/bash rails && \
    chown -R rails:rails /backend
USER rails

# ポート3000を開放
EXPOSE 3000

# Railsサーバーをデフォルトで起動
CMD ["rails", "server", "-b", "0.0.0.0"]
