class Services::Twitter::AccessToken
  include Mongoid::Document
  include Mongoid::Paranoia

  # A string describing the access token.
  field :token, type: String

  # A string describing the access token secret
  field :secret, type: String

  # A Boolean describing whether the access token is invalid.
  field :is_invalid, type: Boolean

  belongs_to :user, class_name: "User"

  validates :user, presence: true

  # Invalidate the access token.
  def invalidate
    UserMailer.access_token_expired_email(user).deliver

    update_attribute :is_invalid, true

    destroy
  end

  # Renew the access token.
  #
  # token   - A String describing a new token
  # secret  - A String describing a new secret
  def renew token, secret
    update_attributes token: token, secret: secret, is_invalid: false
  end

  # Exception raised for invalid access tokens.
  class Invalid < StandardError; end

  # Exception raised when access tokens are exhausted.
  class Exhausted < StandardError; end
end
