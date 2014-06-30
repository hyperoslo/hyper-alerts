require 'test_helper'

class Services::Facebook::AccessTokenTest < ActiveSupport::TestCase
  test "should expire" do
    access_token = create :facebook_access_token

    access_token.expire

    assert ActionMailer::Base.deliveries.any?
    assert_equal Time.now, access_token.expires_at
  end

  test "should deactivate its users facebook subscriptions upon expiring" do
    user         = create :user
    access_token = create :facebook_access_token, user: user
    page         = create :facebook_page
    subscription = create :subscription, user: user, subscribable: page

    access_token.expire

    subscription.reload

    assert_equal true, subscription.deactivated?
  end

  test "should determine whether it expires" do
    access_token = create :facebook_access_token, expires_at: nil

    assert_equal false, access_token.expires?
  end

  test "should determine whether it doesn't expire" do
    access_token = create :facebook_access_token, expires_at: nil

    assert_equal true, access_token.infinite?
  end

  test "should determine whether it has expired" do
    access_token = create :facebook_access_token

    access_token.expire

    assert_equal true, access_token.expired?
  end

  test "should remind users to renew the access token" do
    access_token = create :facebook_access_token

    access_token.remind

    assert_equal Time.now, access_token.reminded_at
    assert ActionMailer::Base.deliveries.any?
  end

  test "should determine whether the user should be reminded to renew it" do
    offset = HyperAlerts::Application.config.access_token_reminder_offset

    access_token = create :facebook_access_token

    access_token.expires_at = offset.from_now - 1.day
    assert_equal true, access_token.remind?

    access_token.expires_at = offset.from_now + 1.day
    assert_equal false, access_token.remind?
  end

  test "should determine whether the user has already been reminded to renew it" do
    access_token = create :facebook_access_token

    access_token.remind

    assert_equal true, access_token.reminded?
  end

  test "should renew itself" do
    user         = create :user
    access_token = create :facebook_access_token, user: user
    page         = create :facebook_page
    subscription = create :subscription, user: user, subscribable: page, deactivated_at: 2.weeks.ago

    new_token      = "<access token>"
    new_expires_at = 2.weeks.from_now

    access_token.renew new_token, new_expires_at

    subscription.reload

    assert_equal new_token, access_token.token
    assert_equal new_expires_at, access_token.expires_at
    assert_equal false, subscription.deactivated?
  end
end
