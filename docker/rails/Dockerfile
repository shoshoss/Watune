# Rubyのバージョンを指定
FROM ruby:3.3

# 必要なパッケージのインストール
# PostgreSQLクライアント、curl、およびその他の依存パッケージをインストール
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# 作業ディレクトリの設定
RUN mkdir backend
# /backend を作業ディレクトリとして使用
WORKDIR /backend

# Bundlerが依存するバージョンのGemをインストールし、bundle installを実行
ADD Gemfile /backend/Gemfile
ADD Gemfile.lock /backend/Gemfile.lock
RUN gem install bundler -v 2.5.6 && bundle _2.5.6_ install

# アプリケーションのコードをコピー
COPY . /backend
