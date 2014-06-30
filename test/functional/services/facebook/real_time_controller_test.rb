require 'test_helper'

class Services::Facebook::RealTimeControllerTest < ActionController::TestCase
  test "should verify new real-time updates" do
    get :verify, verify_token: Rails.configuration.facebook_real_time_updates_verify_token, challenge: "foo"

    assert "foo", response.body
  end

  test "should receive real-time updates for new posts and comments" do
    page = create :facebook_page

    create :subscription, subscribable: page, pushed: true
    create :subscription, subscribable: page, polled: true

    Subscription.
      any_instance.
      expects(
        :schedule
      ).
      once

    post :push, object: :page, entry: [
      id: page.facebook_id,
      changes: [
        {
          field: "feed",
          value: {
            item: "post",
            verb: "add"
          }
        }
      ]
    ]
  end

  test "should ignore real-time updates for anything other than new posts and comments" do
    page = create :facebook_page

    create :subscription, subscribable: page, pushed: true
    create :subscription, subscribable: page, polled: true

    Subscription.
      any_instance.
      expects(
        :schedule
      ).
      never

    post :push, object: :page, entry: [
      id: page.facebook_id,
      changes: [
        {
          field: "feed",
          value: {
            item: "like",
            verb: "add"
          }
        }
      ]
    ]
  end
end
