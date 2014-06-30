require 'test_helper'

class Services::Twitter::SearchTest < ActiveSupport::TestCase
  setup do
    Timecop.freeze
  end

  teardown do
    Timecop.return
  end

  test "should synchronize" do
    user         = create :user
    search       = create :twitter_search
    access_token = create :twitter_access_token, user: user
    tweets       = build_list :twitter_tweet, 5

    search.
      expects(
        :adapter
      ).
      with(
        access_token.token, access_token.secret
      ).
      returns(
        stub search: tweets
      )

    search.synchronize access_token.token, access_token.secret

    assert_equal tweets, search.tweets
  end

  test "should find its subscribers' access tokens" do
    search = create :twitter_search
    users = [
      create(:user),
      create(:user)
    ]
    access_tokens = [
      create(:twitter_access_token, user: users.first),
      create(:twitter_access_token, user: users.last)
    ]
    subscriptions = [
      create(:subscription, user: users.first, subscribable: search, frequency: "*/15 * * * *"),
      create(:subscription, user: users.second, subscribable: search, frequency: "0 * * * *")
    ]

    assert_equal access_tokens, search.access_tokens
  end

  test "should determine what's new for a given subscription" do
    search       = create :twitter_search
    subscription = create :subscription, subscribable: search, notified_at: 4.days.ago
    posts = [
      create(:twitter_tweet, twitter_trackable: search, created_at: 7.days.ago),
      create(:twitter_tweet, twitter_trackable: search, created_at: 2.days.ago),
      create(:twitter_tweet, twitter_trackable: search, created_at: 4.hours.ago)
    ]

    assert_equal true, search.updates_for?(subscription)
  end
end
