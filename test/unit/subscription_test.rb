require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  test "should ignore deactivated subscriptions" do
    create :subscription, deactivated_at: 2.weeks.ago
    create :subscription

    assert_equal 1, Subscription.count
  end

  test "should prohibit itself" do
    subscription = create :subscription

    subscription.prohibit

    assert_equal true, subscription.destroyed?
  end

  test "should determine whether the subscriber has been notified" do
    page         = create :facebook_page
    subscription = create :subscription, subscribable: page, notified_at: nil

    assert_equal false, subscription.notified?

    subscription = create :subscription, subscribable: page, notified_at: 10.minutes.ago

    assert_equal true, subscription.notified?
  end

  test "should determine when the subscriber was last notified" do
    today        = Date.current
    page         = create :facebook_page
    subscription = create :subscription, subscribable: page, frequency: "0 1 * * *"

    Timecop.freeze today do
      assert_equal today - 23.hours, subscription.last_notification_due_at
    end
  end

  test "should determine when the subscriber should be notified" do
    today        = Date.current
    page         = create :facebook_page
    subscription = create :subscription, subscribable: page, frequency: "0 1 * * *"

    Timecop.freeze today do
      assert_equal today + 1.hour, subscription.next_notification_due_at
    end
  end

  test "should determine how long until the subscriber should be notified" do
    today        = Date.current
    page         = create :facebook_page
    subscription = create :subscription, subscribable: page, frequency: "0 2 * * *"

    Timecop.freeze today + 1.hour + 50.minutes do
      assert_equal 10.minutes, subscription.next_notification_due_in
    end
  end

  test "should honor the user's time zone" do
    today        = Date.current
    page         = create :facebook_page
    user         = create :user, time_zone_name: "Stockholm"
    subscription = create :subscription, user: user, subscribable: page, frequency: "0 1 * * *"

    Timecop.freeze today do
      assert_equal today + 0.hours, subscription.next_notification_due_at
    end
  end

  test "should be due if never notified" do
    today        = Date.today
    page         = create :facebook_page
    user         = create :user
    access_token = create :facebook_access_token, user: user
    subscription = create :subscription, user: user, subscribable: page, frequency: "15 * * * *", created_at: today + 12.minutes

    Timecop.travel today + 14.minutes do
      assert_equal false, subscription.due?
    end

    Timecop.travel today + 18.minutes do
      assert_equal true, subscription.due?
    end
  end

  test "should notify the subscriber of new facebook posts" do
    user         = create :user
    access_token = create :facebook_access_token, user: user
    page         = create :facebook_page_with_posts_and_comments
    subscription = create :subscription, user: user, subscribable: page, created_at: 4.weeks.ago

    SubscriptionMailer.
      expects(
        :facebook
      ).
      with(
        subscription
      ).
      returns(
        mock deliver: true
      )

    subscription.notify

    assert_equal Time.now, subscription.notified_at
  end

  test "should notify the subscriber of new tweets" do
    user         = create :user
    access_token = create :twitter_access_token, user: user
    search       = create :twitter_search_with_tweets
    subscription = create :subscription, user: user, subscribable: search, created_at: 4.weeks.ago

    subscription.notify

    assert_equal Time.now, subscription.notified_at
  end

  test "should deactivate itself" do
    subscription = create :subscription

    subscription.deactivate

    assert_equal true, subscription.deactivated?
  end

  test "should activate itself" do
    subscription = create :subscription, deactivated_at: 2.weeks.ago

    subscription.activate

    assert_equal false, subscription.deactivated?
  end

  test "should determine whether it is deactivated" do
    subscription = create :subscription, deactivated_at: 2.weeks.ago

    assert_equal true, subscription.deactivated?
  end

  test "should not save with an invalid frequency" do
    page         = create :facebook_page
    subscription = create :subscription, subscribable: page

    subscription.frequency = "foo bar baz"

    assert_equal false, subscription.save
  end

  test "should enqueue" do
    subscription = create :subscription

    Notification.
      expects(
        :perform_async
      ).
      with(
        subscription.id.to_s
      )

    subscription.enqueue
  end

  test "should subscribe to real-time updates" do
    user         = create :user
    access_token = create :facebook_access_token, user: user
    subscription = create :subscription, user: user

    page = stub identifier: subscription.subscribable.facebook_id

    FbGraph::User.
      any_instance.
      expects(
        :accounts
      ).
      returns(
        [page]
      )

    page.
      expects(
        :tab!
      ).
      with(
        app_id: Rails.configuration.facebook_application_id
      )

    subscription.subscribe_to_real_time_updates
  end

  test "should should determine when it was notified or created" do
    user         = create :user
    access_token = create :facebook_access_token, user: user
    subscription = create :subscription, user: user, notified_at: nil

    assert_equal subscription.created_at, subscription.notified_or_created_at

    subscription.notified_at = Time.now

    assert_equal subscription.notified_or_created_at, Time.now
  end
end
