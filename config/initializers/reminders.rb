# Be sure to restart your server when you modify this file.

HyperAlerts::Application.configure do
  # An integer describing how many seconds before an access token expires its user
  # should be notified to renew it.
  config.access_token_reminder_offset = 1.week
end
