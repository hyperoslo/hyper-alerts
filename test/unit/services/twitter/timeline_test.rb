require 'test_helper'

class Services::Twitter::TimelineTest < ActiveSupport::TestCase
  setup do
    Timecop.freeze
  end

  teardown do
    Timecop.return
  end

  test "should synchronize" do
    user         = create :user
    timeline     = create :twitter_timeline
    access_token = create :twitter_access_token, user: user
    tweets       = build_list :twitter_tweet, 5

    timeline.
      expects(
        :adapter
      ).
      with(
        access_token.token, access_token.secret
      ).
      returns(
        stub timeline: tweets
      )

    timeline.synchronize access_token.token, access_token.secret

    assert_equal tweets, timeline.tweets
  end

  test "should find its subscribers' access tokens" do
    timeline = create :twitter_timeline
    users = [
      create(:user),
      create(:user)
    ]
    access_tokens = [
      create(:twitter_access_token, user: users.first),
      create(:twitter_access_token, user: users.last)
    ]
    subscriptions = [
      create(:subscription, user: users.first, subscribable: timeline, frequency: "*/15 * * * *"),
      create(:subscription, user: users.second, subscribable: timeline, frequency: "0 * * * *")
    ]

    assert_equal access_tokens, timeline.access_tokens
  end
end
