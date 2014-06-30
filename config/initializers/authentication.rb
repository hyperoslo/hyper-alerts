HyperAlerts::Application.configure do
  if ENV["STAGING_USERNAME"] and ENV["STAGING_PASSWORD"]
    config.middleware.insert_after ::Rack::Lock, "::Rack::Auth::Basic", "Staging" do |u, p|
     u == ENV["STAGING_USERNAME"] && p == ENV["STAGING_PASSWORD"]
    end
  end
end
