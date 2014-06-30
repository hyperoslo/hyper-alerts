require 'test_helper'

class Services::Twitter::AdapterTest < ActiveSupport::TestCase

  test "should search tweets" do
    adapter = Services::Twitter::Adapter.new oauth_token: "oauth token",
      oauth_token_secret: "oauth_secret"

    terms = "Ruby on Rails"
    user   = stub id: 1, name: "John Doe", profile_image_url_https: "https://foo.jpg", screen_name: "johndoe"
    status = stub id: 1, text: "I'm a tweet!", created_at: 2.days.ago, user: user

    adapter.client.
      expects(
        :search
      ).
      with(
        terms,
        count: 100
      ).
      returns(
        stub statuses: [status]
      )

    tweets = adapter.search terms

    assert_equal 1, tweets.count

    tweet = tweets.first

    assert_equal 1, tweet.twitter_id
    assert_equal "I'm a tweet!", tweet.text
    assert_equal 2.days.ago, tweet.created_at
    assert_equal 1, tweet.author.twitter_id
    assert_equal "John Doe", tweet.author.name
    assert_equal "johndoe", tweet.author.screen_name
    assert_equal "https://foo.jpg", tweet.author.picture_url
  end

  test "should track timeline" do
    adapter = Services::Twitter::Adapter.new oauth_token: "oauth token",
      oauth_token_secret: "oauth_secret"

    screen_name = "dhh"
    user   = stub id: 1, name: "DHH", profile_image_url_https: "https://foo.jpg", screen_name: "dhh"
    status = stub id: 1, text: "I'm the coolest!", created_at: 2.days.ago, user: user

    adapter.client.
      expects(
        :user_timeline
      ).
      with(
        screen_name,
        count: 100
      ).
      returns(
        [status]
      )

    tweets = adapter.timeline screen_name

    assert_equal 1, tweets.count

    tweet = tweets.first

    assert_equal 1, tweet.twitter_id
    assert_equal "I'm the coolest!", tweet.text
    assert_equal 2.days.ago, tweet.created_at
    assert_equal 1, tweet.author.twitter_id
    assert_equal "DHH", tweet.author.name
    assert_equal "dhh", tweet.author.screen_name
    assert_equal "https://foo.jpg", tweet.author.picture_url
  end

end
