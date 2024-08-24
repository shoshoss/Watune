CarrierWave.configure do |config|
  config.storage    = :aws
  config.aws_bucket = ENV.fetch('R2_BUCKET')
  config.aws_acl    = 'public-read'

  config.aws_credentials = {
    access_key_id: ENV.fetch('R2_ACCESS_KEY'),
    secret_access_key: ENV.fetch('R2_SECRET_KEY'),
    region: 'auto', # R2のリージョン設定
    endpoint: ENV.fetch('R2_ENDPOINT') # R2のエンドポイント
  }
end

CarrierWave.configure do |config|
  config.storage    = :aws
  config.aws_bucket = Rails.application.credentials.dig(:cloudflare, :r2_bucket)
  config.aws_acl    = 'public-read' # 必要に応じて変更

  config.aws_credentials = {
    access_key_id: Rails.application.credentials.dig(:cloudflare, :r2_access_key_id),
    secret_access_key: Rails.application.credentials.dig(:cloudflare, :r2_secret_access_key),
    region: 'auto',
    endpoint: Rails.application.credentials.dig(:cloudflare, :r2_endpoint), # エンドポイントの設定
    force_path_style: true # Cloudflare R2はパススタイルアクセスが必要
  }
end
