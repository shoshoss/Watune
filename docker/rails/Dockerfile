# Rubyのバージョンを指定
FROM ruby:3.3.0

# 必要なパッケージのインストール
# PostgreSQLクライアント、curl、libpq-devおよびその他の依存パッケージをインストール
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client libpq-dev

# /backend を作業ディレクトリとして使用
WORKDIR /backend

# GemfileとGemfile.lockをコピー
COPY Gemfile Gemfile.lock /backend/

# Bundlerをインストールし、bundle installを実行
RUN gem install bundler -v 2.5.6 && bundle _2.5.6_ install

# アプリケーションのコードをコピー
COPY . /backend
