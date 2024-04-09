# syntax = docker/dockerfile:1

# Rubyのバージョンを確認してください。.ruby-versionファイルとGemfileに合わせてください。
ARG RUBY_VERSION=3.3.0
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Railsアプリケーションの作業ディレクトリを設定します。
WORKDIR /gratiwave

# 本番環境用の環境変数、ロケールとタイムゾーンを設定します。
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo

# Gemとnode modulesのビルドに必要なパッケージをインストールします。
FROM base as build
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential curl git libpq-dev libvips node-gyp pkg-config python-is-python3

# JavaScriptの依存関係をインストールします。
ARG NODE_VERSION=21.7.2
ARG YARN_VERSION=1.22.19
ENV PATH=/usr/local/node/bin:$PATH
RUN curl -sL https://github.com/nodenv/node-build/archive/master.tar.gz | tar xz -C /tmp/ && \
    /tmp/node-build-master/bin/node-build "${NODE_VERSION}" /usr/local/node && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /tmp/node-build-master

# Rubyの依存関係をインストールします。
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# node modulesをインストールします。
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# アプリケーションのコードをコピーします。
COPY . .

# アプリケーションの起動を高速化するためにbootsnapを事前コンパイルします。
RUN bundle exec bootsnap precompile app/ lib/

# 本番環境でのアセットプリコンパイル（RAILS_MASTER_KEYが不要）
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# アプリケーションを実行する最終イメージ
FROM base

# デプロイメントに必要なパッケージをインストールします。
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libvips postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# ビルドしたアーティファクトをコピーします。
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /gratiwave /gratiwave

# セキュリティのため、非rootユーザーでアプリケーションを実行します。
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# データベースの準備をするエントリーポイント
ENTRYPOINT ["/gratiwave/bin/docker-entrypoint"]

# デフォルトでRailsサーバーを起動します。
EXPOSE 3000
CMD ["./bin/rails", "server"]
