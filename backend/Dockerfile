# Rails バックエンド用の Dockerfile
FROM ruby:3.3
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

# 作業ディレクトリの作成と設定
RUN mkdir /app
WORKDIR /app

# Bundler と Gems のインストール
COPY Gemfile Gemfile.lock /app/
RUN gem install bundler && bundle install

# アプリケーションのコードをコピー
COPY . /app
