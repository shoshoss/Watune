# Rubyのバージョンを指定
ARG RUBY_VERSION=3.3.0
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

WORKDIR /rails

# 環境変数の設定
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo 

# Throw-away build stage to reduce size of final image
FROM base as build

# 依存関係のインストール。Node.jsとYarnの安定版をインストールします。
RUN apt-get update -qq && \
    apt-get install -y ca-certificates curl gnupg build-essential libpq-dev libssl-dev git pkg-config && \
    curl -fsSL https://deb.nodesource.com/setup_21.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# GemfileとGemfile.lockをコピーし、Bundlerと依存関係をインストール
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:2.5.6 && \
    bundle install --without development test --retry 3 --jobs 4 && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Yarnの依存関係をインストール
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# アプリケーションのソースコードをコピー
COPY . .

# bootsnapを利用したアプリケーションの起動の高速化
RUN bundle exec bootsnap precompile --gemfile && \
    bundle exec bootsnap precompile

# 本番環境でのアセットプリコンパイル（RAILS_MASTER_KEYが不要）
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# セキュリティのため、非rootユーザーでアプリケーションを実行します。
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start the server by default, this can be overwritten at runtime
EXPOSE 3000
CMD ["./bin/rails", "server"]
