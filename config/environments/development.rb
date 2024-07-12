# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Rails.application.configure do
  # Webコンソールにアクセスを許可するIPアドレスを追加
  config.web_console.permissions = ['172.19.0.4', '127.0.0.0/8', '::1', '192.168.65.1']

  config.hosts.clear
  # ここに指定された設定はconfig/application.rbよりも優先されます。

  # 開発環境では、アプリケーションのコードは変更があるたびにリロードされます。
  # これにより、応答時間が遅くなりますが、コード変更時にサーバーを再起動する必要がありません。
  config.enable_reloading = true

  # 起動時にコードをイージャーロードしません。
  config.eager_load = false

  # フルエラーレポートを表示します。
  config.consider_all_requests_local = true

  # サーバータイミングを有効にします。
  config.server_timing = true

  # キャッシュを有効/無効にします。デフォルトではキャッシュは無効です。
  # キャッシュを切り替えるには`rails dev:cache`を実行します。
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # アップロードファイルはローカルファイルシステムに保存されます（オプションはconfig/storage.ymlを参照）。
  # Cloudflare R2 を使う
  config.active_storage.service = :cloudflare

  # メール送信が失敗しても気にしません。
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # メール送信方法をletter_opener_webに設定します。
  config.action_mailer.delivery_method = :letter_opener_web
  config.action_mailer.default_url_options = Settings.default_url_options.to_h

  # 非推奨の通知をRailsロガーに出力します。
  config.active_support.deprecation = :log

  # 非許容の非推奨通知に対して例外を発生させます。
  config.active_support.disallowed_deprecation = :raise

  # 非許容の非推奨メッセージを指定します。
  config.active_support.disallowed_deprecation_warnings = []

  # マイグレーションが保留中の場合にページロードでエラーを発生させます。
  config.active_record.migration_error = :page_load

  # データベースクエリをログに表示するコードをハイライトします。
  config.active_record.verbose_query_logs = true

  # 背景ジョブをキューに追加したコードをログに表示します。
  config.active_job.verbose_enqueue_logs = true

  # アセットリクエストのロガー出力を抑制します。
  config.assets.quiet = true

  # 翻訳が見つからない場合にエラーを発生させます。
  # config.i18n.raise_on_missing_translations = true

  # レンダリングされたビューにファイル名を注釈します。
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Action Cableが任意のオリジンからのアクセスを許可する場合はコメントを外します。
  # config.action_cable.disable_request_forgery_protection = true

  # before_actionのonly/exceptオプションが存在しないアクションを参照する場合にエラーを発生させます。
  config.action_controller.raise_on_missing_callback_actions = true

  config.assets.debug = true
  config.assets.digest = true
  config.assets.compile = true

  # Active Jobのキューアダプタを設定します。開発環境ではデフォルトで:asyncが使用されます。
  config.active_job.queue_adapter = :async
end
