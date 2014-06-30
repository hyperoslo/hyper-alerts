class Services::Twitter::Adapter
  BATCH = 100

  attr_reader :client, :terms

  # Initialize the adapter.
  #
  # credentials        - A hash of credentials:
  #                      :oauth_token - A string describing a Twitter access token.
  #                      :oauth_token_secret - A string describing a Twitter access token secret.
  def initialize credentials
    @client = Twitter::Client.new credentials
  end

  # Search tweets.
  #
  # terms - A string describing search terms
  # limit - An integer describing how many tweets to load.
  #
  # Returns an Array of Services::Twitter::Tweet instances.
  def search terms, limit = 100
    result = @client.search terms, count: limit

    result.statuses.map do |status|
      tweet status
    end
  rescue Twitter::Error::Unauthorized
    raise Services::Twitter::AccessToken::Invalid
  end

  # Track user timeline.
  #
  # user - A string describing the users screen name or ID
  # limit - An integer describing how many tweets to load.
  #
  # Returns an Array of Services::Twitter::Tweet instances.
  def timeline user, limit = 100
    result = @client.user_timeline user, count: limit

    result.map! do |status|
      tweet status
    end
  rescue Twitter::Error::Unauthorized
    raise Services::Twitter::AccessToken::Invalid
  end

  private

  # Query tweets.
  #
  # tweet_id - An integer identifying the last tweet to query (non-inclusive).
  #
  # Returns whatever the API endpoint you are using returns.
  def query tweet_id = nil
    parameters = {}.tap do |hash|
      hash.store :count, BATCH
      hash.store :max_id, tweet_id if tweet_id
    end

    yield @client, parameters
  end

  # Initialize a new tweet from Twitter data
  #
  # data - An Twitter::Tweet instance
  #
  # Returns a Services::Twitter::Tweet instance
  def tweet data
    Services::Twitter::Tweet.new do |t|
      t.twitter_id = data.id
      t.text       = data.text
      t.created_at = data.created_at
      t.author     = user data.user
    end
  end

  # Initialize a new user from Twitter data.
  #
  # data - A Twitter::User instance.
  #
  # Returns a Services::Twitter::User instance.
  def user data
    Services::Twitter::User.new do |u|
      u.twitter_id  = data.id
      u.name        = data.name
      u.picture_url = data.profile_image_url_https
      u.screen_name = data.screen_name
    end
  end
end
