# config/initializers/redis.rb

# Redisの設定
redis_config = { url: ENV.fetch("REDIS_URL") { "redis://localhost:6379/1" } }

# RailsのキャッシュストアにRedisを使用
Rails.application.config.cache_store = :redis_cache_store, { url: redis_config[:url] }

# RailsのセッションストアにRedisを使用
Rails.application.config.session_store :redis_store, servers: redis_config[:url], expires_in: 90.minutes
