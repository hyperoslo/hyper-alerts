require 'test_helper'

class SubscriptionMailerTest < ActionMailer::TestCase
  test "facebook" do
    user         = create :user
    page         = create :facebook_page, name: "Ruby on Rails"
    photo        = create :facebook_photo, page: page, created_at: 1.week.ago
    post         = create :facebook_post, page: page, created_at: 1.week.ago
    comment      = create :facebook_comment, commentable: post, created_at: 1.week.ago
    reply        = create :facebook_comment, commentable: comment, created_at: 5.days.ago
    subscription = create :subscription, scope: ["posts", "comments"], user: user, subscribable: page, notified_at: 2.years.ago

    email = SubscriptionMailer.facebook subscription

    assert_equal [user.email], email.to
    assert_equal "[Ruby on Rails] 2 new posts and 2 new comments", email.subject
  end

  test "twitter search" do
    user         = create :user
    access_token = create :twitter_access_token, user: user
    search       = create :twitter_search, terms: "#rails"
    tweet        = create :twitter_tweet, twitter_trackable: search, created_at: 1.week.ago
    subscription = create :subscription, user: user, subscribable: search, notified_at: 2.weeks.ago

    email = SubscriptionMailer.twitter_search(subscription).deliver

    assert_equal [user.email], email.to
    assert_equal "[#rails] 1 new tweets", email.subject
  end

  test "twitter timeline" do
    user         = create :user
    access_token = create :twitter_access_token, user: user
    timeline     = create :twitter_timeline, name: "dhh"
    tweet        = create :twitter_tweet, twitter_trackable: timeline, created_at: 1.week.ago
    subscription = create :subscription, user: user, subscribable: timeline, notified_at: 2.weeks.ago

    email = SubscriptionMailer.twitter_timeline(subscription).deliver

    assert_equal [user.email], email.to
    assert_equal "[dhh] 1 new tweets", email.subject
  end

end
