# 本番環境の設定
Rails.application.configure do
  # ここに指定された設定はconfig/application.rbよりも優先されます。

  # リクエスト間でコードをリロードしません。
  config.enable_reloading = false

  # 起動時にコードをイージャーロードします。
  config.eager_load = true

  # フルエラーレポートを無効にし、キャッシュを有効にします。
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # 静的ファイルを`public/`から提供するのを無効にします。NGINX/Apacheを使用することを前提としています。
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present? || ENV['RENDER'].present?

  # Cloudflare R2 を使う
  config.active_storage.service = :cloudflare

  # SSL経由でのアクセスを強制し、Strict-Transport-Securityを使用し、セキュアクッキーを使用します。
  config.force_ssl = true

  # ログをSTDOUTに出力します。
  config.logger = ActiveSupport::Logger.new($stdout)
                                       .tap { |logger| logger.formatter = Logger::Formatter.new }
                                       .then { |logger| ActiveSupport::TaggedLogging.new(logger) }

  # すべてのログ行の前にリクエストIDタグを追加します。
  config.log_tags = [:request_id]

  # ログレベルを設定します。デフォルトは「info」です。
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')

  # Active Jobのキューアダプタを設定します。
  config.active_job.queue_adapter = :sidekiq

  # メール設定
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = Settings.default_url_options.to_h
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_options = { charset: 'utf-8' }
  config.action_mailer.smtp_settings = {
    enable_starttls_auto: true,
    address: 'smtp.gmail.com',
    port: 587,
    domain: 'smtp.gmail.com',
    user_name: ENV.fetch('GMAIL_ADDRESS', nil),
    password: ENV.fetch('GMAIL_PASSWORD', nil),
    authentication: 'login'
  }

  # I18nのロケールフォールバックを有効にします。
  config.i18n.fallbacks = true

  # 非推奨のログを出力しません。
  config.active_support.report_deprecations = false

  # マイグレーション後にスキーマをダンプしません。
  config.active_record.dump_schema_after_migration = false

  config.assets.css_compressor = nil

  # DNSリバインディング保護とその他の`Host`ヘッダー攻撃を有効にします。
  config.hosts << 'wavecongra.onrender.com'
  config.hosts << 'www.wavecongra.com'
  config.hosts << 'wavecongra.com'
  config.hosts << 'www.watune.com'
  config.hosts << 'watune.com'

  config.middleware.insert_before(Rack::Runtime, Rack::Rewrite) do
    r301 /.*/, 'https://www.watune.com$&', if: Proc.new { |rack_env|
      ['wavecongra.onrender.com', 'www.wavecongra.com', 'wavecongra.com'].include?(rack_env['SERVER_NAME'])
    }
  end  
end
