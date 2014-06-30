class User
  include Mongoid::Document

  devise :confirmable, :trackable, :omniauthable, :token_authenticatable

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  # Confirmable
  field :confirmation_token,   type: String
  field :confirmed_at,         type: Time
  field :confirmation_sent_at, type: Time
  field :unconfirmed_email,    type: String

  # Omniauthable
  field :provider, type: String
  field :uid, type: String

  ## Token authenticatable
  field :authentication_token, type: String

  before_save :ensure_authentication_token

  # A String describing the user's name.
  field :name, type: String

  # A String describing the user's e-mail address.
  field :email, type: String

  # A String describing the user's secret token from Hyper Alerts 1.
  field :legacy_id, type: String

  # A String describing the name of the user's time zone.
  field :time_zone_name, type: String, default: "UTC"

  # A Time instance describing when the user's e-mail address started bouncing.
  field :bouncing_since, type: Time

  # A Services::Facebook::AccessToken instance.
  has_one :facebook_access_token, class_name: "Services::Facebook::AccessToken"

  # A Services::Twitter::AcessToken instance.
  has_one :twitter_access_token, class_name: "Services::Twitter::AccessToken"

  # An Invitation instance.
  has_one :invitation

  # A collection of Subscription instances.
  has_many :subscriptions, dependent: :destroy do
    def facebook
      where subscribable_type: "Services::Facebook::Page"
    end

    def twitter_search
      where subscribable_type: "Services::Twitter::Search"
    end

    def twitter_timeline
      where subscribable_type: "Services::Twitter::Timeline"
    end
  end

  validates :email, uniqueness: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, allow_blank: true }

  before_save do |user|
    user.bouncing_since = nil if user.email_changed?
  end

  # Determine whether the user subscribes to the given subscribable.
  #
  # subscirbable - An instance of a subscribable model.
  def subscribes_to? subscribable
    subscriptions.any? do |subscription|
      subscription.subscribable == subscribable
    end
  end

  # Query Facebook for the user.
  #
  # * options - A Hash of options:
  #             :lazy - A Boolean describing whether to defer the query to Facebook.
  #
  # Returns a FbGraph::User instance.
  def graph options = {}
    user = FbGraph::User.new "me", access_token: facebook_access_token.token

    unless options[:lazy]
      user.fetch
    else
      user
    end
  end

  def time_zone
    ActiveSupport::TimeZone.new time_zone_name
  end

  # Determine whether the user's e-mails are bouncing.
  #
  # Returns a Boolean.
  def bouncing?
    !!bouncing_since
  end

  def to_s
    email
  end
end
