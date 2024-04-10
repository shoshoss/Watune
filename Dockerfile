# Rubyのバージョンを指定
ARG RUBY_VERSION=3.3.0
FROM ruby:$RUBY_VERSION-slim

WORKDIR /gratiwave

# 環境変数の設定
ENV BUNDLE_PATH="/usr/local/bundle" \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo \
    PATH="/gratiwave/bin:${PATH}"

# 依存関係のインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl git libpq-dev libvips nodejs npm && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Node.jsとYarnのインストール。最新の安定バージョンを使用。
RUN npm install -g yarn

# GemfileとGemfile.lockをコピーし、Bundlerと依存関係をインストール
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:2.5.6 && \
    bundle install --binstubs

# Yarnの依存関係をインストール
COPY package.json yarn.lock ./
RUN yarn install

# アプリケーションのソースコードをコピー
COPY . .

# JavaScriptとCSSのビルドに加えて、アセットプリコンパイルを実行
RUN bin/rails javascript:build
RUN bin/rails css:build
RUN RAILS_ENV=production bin/rails assets:precompile

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
