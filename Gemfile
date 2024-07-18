# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.3.0'

# Railsのバージョンを指定
gem 'rails', '~> 7.1.3', '>= 7.1.3.2'

# Asset Pipelineを利用
gem 'sprockets-rails'

# Active RecordのデータベースとしてPostgreSQLを使用
gem 'pg', '~> 1.5'

# WebサーバーにPumaを利用
gem 'puma', '>= 5.0'

# ESM import mapsでJavaScriptを使用
gem 'importmap-rails'

# Turboを利用したSPA風のページアクセラレータ
gem 'turbo-rails'

# Stimulus.jsを利用したJavaScriptフレームワーク
gem 'stimulus-rails'

# CSSをバンドルおよび処理
gem 'cssbundling-rails'

# JSON APIを簡単に構築
gem 'jbuilder'

# Redisとの通信を行うための基本的なクライアントライブラリ
gem 'redis', '>= 5.2'

# Redisを利用してデータを一時的に保存するための設定を容易にするライブラリ
gem 'redis-rails', '>= 5.0'

gem 'sidekiq', '>= 7.2'

# Redisで高度なデータ型を取得するためのKredis
# gem 'kredis'

# Active Modelでhas_secure_passwordを使用
# gem 'bcrypt', '~> 3.1.7'

# Windowsにはzoneinfoファイルが含まれていないため、tzinfo-data gemをバンドル
gem 'tzinfo-data', platforms: %i[windows jruby]

# 起動時間を短縮するためのbootsnap
gem 'bootsnap', require: false

# Active Storageのバリアントを使用
# gem 'image_processing', '~> 1.2'

# ユーザー認証のためのsorcery
gem 'sorcery', '~> 0.17'

# ローカライズのためのrails-i18n
gem 'rails-i18n', '~> 7.0'

# 設定ファイルの管理のためのconfig
gem 'config', '~> 5.4'

# ファイルのアップロードのためのcarrierwave
gem 'carrierwave', '~> 3.0'

# ページネーションのためのpagy
gem 'pagy', '~> 8.3'

gem 'aws-sdk-s3', '~> 1.1', require: false

gem 'active_record_extended', '~> 3.2'

# https://アプリ名.onrender.com」を、「https://www.独自ドメイン」にリダイレクトさせてドメインを統一
gem 'rack-rewrite', '~> 1.5'

# OGPメタタグの設定を効率的に行うため
gem 'meta-tags', '~> 2.21'

gem 'enum_help'

gem 'rails_autolink', '~> 1.1'

group :development, :test do
  # リクエストの速度を表示するためのrack-mini-profiler
  gem 'rack-mini-profiler', '>= 3.3', require: false

  # N+1クエリの検出や未使用のEager Loadの警告のためのbullet
  gem 'bullet', '>= 7.1', require: false

  # デバッグ用のdebug
  gem 'debug', platforms: %i[mri windows]
  gem 'flamegraph', '>= 0.9'
  gem 'stackprof', '>= 0.2'

  # テスト用のダミーデータ生成のためのfaker
  gem 'faker', '>= 3.3'

  # メールのプレビューのためのletter_opener_web
  gem 'letter_opener_web', '>= 2.0'
end

group :development do
  # 開発環境でのコンソール表示のためのweb-console
  gem 'web-console'

  # 開発環境でのコマンドの高速化のためのspring
  # gem 'spring'
end

group :test do
  # システムテストのためのcapybara
  gem 'capybara', '>= 3.4'

  # テストデータの作成のためのfactory_bot_rails
  gem 'factory_bot_rails', '>= 6.4'

  # テストフレームワークのRSpec
  gem 'rspec-rails', '>= 6.1'

  # コードの静的解析のためのrubocop
  gem 'rubocop', '>= 1.63', require: false
  gem 'rubocop-capybara', '>= 2.20', require: false
  gem 'rubocop-factory_bot', '>= 2.25'
  gem 'rubocop-rails', '>= 2.24', require: false
  gem 'rubocop-rspec', '>= 2.28', require: false

  # ブラウザテストのためのselenium-webdriver
  gem 'selenium-webdriver', '>= 4.10'

  # ブラウザドライバの管理のためのwebdrivers
  gem 'webdrivers', '>= 5.3'
end
