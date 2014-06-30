class Services::Facebook::AccessToken
  include Mongoid::Document

  # A string describing the access token.
  field :token, type: String

  # A Time instance describing when the access token expires.
  field :expires_at, type: Time

  # A Time instance describing when the user was reminded to renew the access token.
  field :reminded_at, type: Time

  belongs_to :user, class_name: "User"

  validates :token, presence: true
  validates :user, presence: true

  # Expire the access token.
  def expire
    touch :expires_at

    user.subscriptions.facebook.each do |subscription|
      subscription.deactivate
    end

    UserMailer.access_token_expired_email(user).deliver
  end

  # Return a boolean describing whether the access token has expired.
  def expired?
    if expires?
      Time.now >= expires_at
    else
      false
    end
  end

  # Return a boolean describing whether the access token expires.
  def expires?
    !!expires_at
  end

  # Return a boolean describing whether the access token is infinite.
  def infinite?
    !expires?
  end

  # Returns an integer describing seconds until the access token expires,
  # or nil if it will never expire.
  def expires_in
    if expires_at
      expires_at - Time.now
    else
      nil
    end
  end

  # Return a boolean describing whether the user has been reminded to renew his/her
  # access token.
  def reminded?
    !!reminded_at
  end

  # Determine whether the user should be reminded to renew the access token.
  def remind?
    offset = HyperAlerts::Application.config.access_token_reminder_offset

    if reminded?
      return false
    end

    if infinite?
      return false
    end

    if expires_at > offset.from_now
      return false
    end

    if user.email.blank?
      return false
    end

    true
  end

  # Remind the user to renew the access token.
  def remind 
    touch :reminded_at

    UserMailer.access_token_renewal_reminder(user).deliver
  end

  # Renew the access token.
  #
  # access_token - A String describing a new access token.
  # expires_at   - A Time instance describing when the access token expires.
  def renew access_token, expires_at
    update_attributes token: access_token, expires_at: expires_at, reminded_at: nil

    user.subscriptions.facebook.unscoped.each do |subscription|
      subscription.activate
    end
  end

  # Exception raised for invalid access tokens.
  class Invalid < StandardError; end
end
