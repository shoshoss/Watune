# Rails バックエンド用の Dockerfile
FROM ruby:3.3
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

# PostgreSQLクライアントをインストールします。データベースへの接続に必要です。
RUN apt-get update -qq && apt-get install -y postgresql-client

# アプリケーション用のディレクトリを作成します。
RUN mkdir /app
WORKDIR /app

# Bundlerをインストールし、Gemfileに基づいて必要なGemをインストールします。
COPY Gemfile Gemfile.lock /app/
RUN gem install bundler && bundle install

# Railsアプリケーションが起動する際に前回のプロセスIDが残っているとエラーになるため、
# エントリーポイントスクリプトを使用してそれを削除します。
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# アプリケーションのコードをコピーします。
COPY . /app

# entrypoint.shの内容も適切ですが、`/backend/tmp/pids/server.pid`のパスが`/app/tmp/pids/server.pid`であるべきか確認してください。
# Dockerfileと同じディレクトリにあるentrypoint.shを編集してください。
