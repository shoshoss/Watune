# config/initializers/rack_profiler.rb
if Rails.env.development?
  require 'rack-mini-profiler'
  
  # rack-mini-profilerを無効にする設定
  Rack::MiniProfiler.config.enabled = false
end
