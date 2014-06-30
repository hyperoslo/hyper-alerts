require "sidekiq/web"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"] }

  config.failures_default_mode = :exhausted

  config.server_middleware do |chain|
    chain.add Kiqstand::Middleware
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"] }
end

Sidekiq::Web.use Rack::Auth::Basic do |user, password|
  user     == ENV["SIDEKIQ_USERNAME"]
  password == ENV["SIDEKIQ_PASSWORD"]
end
