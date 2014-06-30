class Services::Twitter::Search < Services::Twitter::Base
  include Concerns::Synchronizable
  include Concerns::Subscribable

  # A comma-seperated list of phrases to track
  field :terms, type: String

  # A collection of Twitter::Tweet instances.
  embeds_many :tweets, class_name: "Services::Twitter::Tweet", as: :twitter_trackable

  # A collection of Services::Benchmark instances.
  has_many :benchmarks, as: :benchmarkable, class_name: "Services::Benchmark"

  validates :terms, presence: true

  # Synchronize the search using the given access token and access token secret.
  #
  # access_token         - A String describing an access token.
  # access_token_secret  - A String describing an access token secret.
  def synchronize access_token, access_token_secret
    benchmarks.create.measure do
      adapter = adapter access_token, access_token_secret

      self.tweets = adapter.search terms

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
    terms
  end
end
