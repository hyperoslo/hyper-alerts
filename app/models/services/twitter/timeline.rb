class Services::Twitter::Timeline < Services::Twitter::Base
  include Concerns::Synchronizable
  include Concerns::Subscribable

  # An Integer describing the Twitter ID of the user
  field :twitter_id, type: Integer

  # A String describing the name of the user
  field :name, type: String

  # A String describing the screen name of the user
  field :screen_name, type: String

  # A String describing the path to the avatar of the user
  field :picture_url, type: String

  # A collection of Services::Benchmark instances.
  has_many :benchmarks, as: :benchmarkable, class_name: "Services::Benchmark"

  # A collection of Twitter::Tweet instances.
  embeds_many :tweets, class_name: "Services::Twitter::Tweet", as: :twitter_trackable

  validates :twitter_id, presence: true, uniqueness: true

  # Synchronize the timeline using the given access token and access token secret.
  #
  # access_token         - A String describing an access token.
  # access_token_secret  - A String describing an access token secret.
  def synchronize access_token, access_token_secret
    benchmarks.create.measure do
      adapter = adapter access_token, access_token_secret

      self.tweets = adapter.timeline twitter_id

      self.save!

      mark_as_synchronized
    end
  end

  # Return an array of AccessToken instances describing access tokens of users who subscribe to this search.
  def access_tokens
    subscribers.map { |s| s.twitter_access_token }
  end

  # Initialize an adapter with the given access token.
  #
  # access_token        - A String describing an access token.
  # access_token_secret - A String describing an access token secret.
  #
  # Returns an Adapters::Twitter instance.
  def adapter access_token, access_token_secret
    Services::Twitter::Adapter.new oauth_token: access_token, oauth_token_secret: access_token_secret
  end

  def to_s
    screen_name
  end
end
