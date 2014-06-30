require "./config/boot"
require "./config/environment"

include Clockwork

every 5.minutes, "Schedule digests", thread: true do
  Subscription.polled.each do |subscription|
    subscription.schedule unless subscription.scheduled?
  end
end

every 1.day, "Access token reminders", thread: true do
  Services::Facebook::AccessToken.each do |token|
    token.remind if token.remind?
  end
end
