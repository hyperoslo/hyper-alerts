require "digest/sha1"

# API client for the legacy version of Hyper Alerts.
class Legacy
  include HTTParty

  base_uri "old.hyperalerts.no"

  format :json

  # email    - A String describing an e-mail address
  # password - A String describing a password.
  def initialize email, password
    self.class.default_params email: email, password: hash(password)
  end

  # Load subscriptions for the given account.
  def subscriptions
    response = self.class.get "/GetSubscriptions"

    success = response.fetch "success"

    if success
      subscriptions = response.fetch "subscriptions"

      return subscriptions.map do |subscription|
        create_subscription subscription
      end.compact
    else
      raise Error, response.fetch("error")
    end
  end

  # Disable subscriptions for the given account.
  def disable
    response = self.class.get "/DisableSubscriptions"

    success = response.fetch "success"

    if success
      return true
    else
      raise Error, response.fetch("error")
    end
  end

  private

  # Create a Subscription from the given hash.
  #
  # hash - A Hash describing a subscription from the legacy API.
  #
  # Returns a new Subscription instance.
  def create_subscription hash
    facebook_page_id = hash.fetch "page"
    hour             = hash.fetch "hour"
    day              = hash.fetch "day"

    case hash.fetch "type"
    when "monthly"
      frequency = "0 0 1 * *"
      preset    = "monthly"
    when "weekly"
      frequency = "0 #{hour} * * #{day}"
      preset    = "weekly"
    when "daily"
      frequency = "0 #{hour} * * *" 
      preset    = "daily"
    when "hourly"
      frequency = "0 * * * *"
      preset    = "hourly"
    when "asap"
      frequency = "*/10 * * * *"
      preset    = "as soon as possible"
    else
      frequency = "0 * * * *" 
      preset    = "daily"
    end

    page = Services::Facebook::Page.find_or_create_by facebook_id: facebook_page_id
    page.synchronize nil, only: [:name, :likes]

    Subscription.new do |s|
      s.subscribable = page
      s.preset       = preset
      s.frequency    = frequency
      s.scope        = ["posts", "comments"]
      s.polled       = true
      s.pushed       = false
    end

  rescue Services::Facebook::Page::Inaccessible
    nil
  end

  # Hash the given string using SHA1.
  #
  # string - A String to hash.
  def hash string
    Digest::SHA1.hexdigest string
  end

  class Error < StandardError; end
end
