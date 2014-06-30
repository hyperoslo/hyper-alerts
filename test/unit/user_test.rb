require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "should query its Graph API representation" do
    user                  = build :user
    facebook_access_token = build :facebook_access_token, user: user

    FbGraph::User.
      any_instance.
      expects(
        :fetch
      )

    user.graph
  end

  test "should determine whether it subscribes to a given subscribable" do
    user            = create :user
    orphaned_page   = create :facebook_page
    subscribed_page = create :facebook_page
    subscription    = create :subscription, user: user, subscribable: subscribed_page

    assert_equal true, user.subscribes_to?(subscribed_page)
    assert_equal false, user.subscribes_to?(orphaned_page)
  end

  test "should filter subscriptions by type" do
    user         = create :user

    search       = create :twitter_search
    subscription = create :subscription, user: user, subscribable: search

    assert_equal [subscription], user.subscriptions.twitter_search.to_a

    page         = create :facebook_page
    subscription = create :subscription, user: user, subscribable: page

    assert_equal [subscription], user.subscriptions.facebook.to_a
  end

  test "should not be bouncing after changing their e-mail address" do
    user = create :user, email: "john@doe.com", bouncing_since: 2.days.ago

    user.email = "jane@doe.com"

    user.save

    assert_equal false, user.bouncing?
  end
end
