# Rubyのバージョンを修正
FROM ruby:3.3
ENV LANG C.UTF-8
ENV TZ Asia/Tokyo

# PostgreSQLクライアントと必要なパッケージを一度にインストール
RUN apt-get update -qq && apt-get install -y postgresql-client curl apt-transport-https wget && \
  rm -rf /var/lib/apt/lists/*

# 作業ディレクトリを/backendに設定
RUN mkdir /backend
WORKDIR /backend

# BundlerとGemの依存関係をインストール
COPY Gemfile Gemfile.lock /backend/
RUN gem install bundler -v 2.5.6 && bundle _2.5.6_ install

# エントリーポイントスクリプトをコピーして実行可能に設定
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# アプリケーションのコードをコピー
COPY . /backend

# Railsサーバーを起動するための設定
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
