require 'test_helper'

class LegacyTest < ActiveSupport::TestCase
  setup do
    @legacy = Legacy.new "user@domain.tld", "password"
  end

  test "should load subscriptions" do
    Legacy.
      expects(
        :get
      ).
      with(
        "/GetSubscriptions"
      ).
      returns(
        "success" => true,
        "subscriptions" => [
          {
            "page" => "165840708864",
            "type" => "daily",
            "hour" => "10",
            "day" => "1"
          }
        ]
      )

    Services::Facebook::Page.
      any_instance.
      expects(
        :synchronize
      ).
      with(
        nil, only: [:name, :likes]
      )

    subscriptions = @legacy.subscriptions

    assert_equal 1, subscriptions.count

    subscription = subscriptions.first

    assert_equal "0 10 * * *", subscription.frequency
    assert_equal "daily", subscription.preset
  end

  test "should raise an error upon failing to load subscriptions" do
    Legacy.
      expects(
        :get
      ).
      with(
        "/GetSubscriptions"
      ).
      returns(
        "success" => false,
        "error" => "No account with that email exists"
      )

    assert_raises Legacy::Error do
      @legacy.subscriptions
    end
  end

  test "should disable subscriptions" do
    Legacy.
      expects(
        :get
      ).
      with(
        "/DisableSubscriptions"
      ).
      returns(
        "success" => true,
        "subscriptions" => [
          {
            "page" => "165840708864",
            "type" => "daily",
            "hour" => "10",
            "day" => "1"
          }
        ]
      )

    @legacy.disable
  end
end
