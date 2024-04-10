# Rubyのバージョンを指定
ARG RUBY_VERSION=3.3.0
FROM ruby:$RUBY_VERSION-slim

WORKDIR /gratiwave

# 環境変数の設定
ENV RAILS_ENV="production" \
    BUNDLE_PATH="/usr/local/bundle" \
    LANG=C.UTF-8 \
    TZ=Asia/Tokyo \
    PATH="/gratiwave/bin:${PATH}"

# 依存関係のインストール。Node.jsとYarnの安定版をインストールします。
RUN apt-get update -qq && \
    apt-get install -y ca-certificates curl gnupg build-essential libpq-dev libssl-dev && \
    curl -fsSL https://deb.nodesource.com/setup_21.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g yarn && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# GemfileとGemfile.lockをコピーし、Bundlerと依存関係をインストール
COPY Gemfile Gemfile.lock ./
RUN gem install bundler:2.5.6 && \
    bundle install --without development test --retry 3 --jobs 4
    RUN bundle exec bootsnap precompile --gemfile

# Yarnの依存関係をインストール
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# アプリケーションのソースコードをコピー
COPY . .

# アプリケーションの起動を高速化するためにbootsnapを事前コンパイルします。
RUN bundle exec bootsnap precompile app/ lib/

# アセットプリコンパイル。cssbundling-railsとjsbundling-railsのビルドコマンドを使用
RUN  SECRET_KEY_BASE=${SECRET_KEY_BASE} bin/rails assets:precompile

# ビルドしたアーティファクトをコピーします。
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /gratiwave /gratiwave

# セキュリティのため、非rootユーザーでアプリケーションを実行します。
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

## Add a script to be executed every time the container starts.
COPY bin/render-build.sh /usr/bin/
RUN chmod a+x bin/render-build.sh
ENTRYPOINT ["render-build.sh"]
EXPOSE 3000

## Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
