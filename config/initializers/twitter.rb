# Be sure to restart your server when you modify this file.

Twitter.configure do |config|
  config.consumer_key    = HyperAlerts::Application.config.twitter_consumer_key
  config.consumer_secret = HyperAlerts::Application.config.twitter_consumer_secret
end
