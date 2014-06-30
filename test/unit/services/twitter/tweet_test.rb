require 'test_helper'

class Services::Twitter::TweetTest < ActiveSupport::TestCase
  test "should derive its url" do
    timeline = create :twitter_timeline
    tweet    = create :twitter_tweet, twitter_trackable: timeline
    author   = create :twitter_user, authorable: tweet

    assert_equal "https://twitter.com/#{author.screen_name}/status/#{tweet.twitter_id}", tweet.url
  end
end
