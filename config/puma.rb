# frozen_string_literal: true

# Puma configuration file.

max_threads_count = ENV.fetch('RAILS_MAX_THREADS', 5).to_i
min_threads_count = ENV.fetch('RAILS_MIN_THREADS', max_threads_count).to_i
threads min_threads_count, max_threads_count

# Use the `worker_timeout` to wait before terminating a worker in development environments.
worker_timeout 3600 if ENV.fetch('RAILS_ENV', 'development') == 'development'

port        ENV.fetch('PORT', 3000)

environment ENV.fetch('RAILS_ENV', 'development')

pidfile ENV.fetch('PIDFILE', 'tmp/pids/server.pid')

plugin :tmp_restart

# Worker processes are only enabled in production environment
if ENV.fetch('RAILS_ENV', 'development') == 'production'
  require 'concurrent-ruby'
  worker_count = Integer(ENV.fetch('WEB_CONCURRENCY', Concurrent.physical_processor_count))
  workers worker_count if worker_count > 1
  # Preload the application before starting the workers; this is recommended for performance.
  preload_app!
end

