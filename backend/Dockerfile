# Rails バックエンド用の Dockerfile
FROM ruby:3.3
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

# Node.js と Yarn のインストール
RUN curl -sL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get update -qq \
  && apt-get install -y nodejs yarn

# 作業ディレクトリの作成と設定
RUN mkdir /app
WORKDIR /app

# Bundler と Gems のインストール
RUN gem install bundler
COPY Gemfile Gemfile.lock /app/
RUN bundle install

# アプリケーションのコードをコピー
COPY . /app
