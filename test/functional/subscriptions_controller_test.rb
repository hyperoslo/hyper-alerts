require 'test_helper'

class SubscriptionsControllerTest < ActionController::TestCase
  setup do
    @user = create :user
    @access_token = create :facebook_access_token, user: @user

    sign_in @user
  end

  test "should render a list of subscriptions as HTML" do
    subscriptions = [
      create(:subscription, user: @user),
      create(:subscription, user: @user)
    ]

    get :index, format: :html

    assert_response :success
  end

  test "should render a list of subscriptions as JSON" do
    subscriptions = [
      create(:subscription, user: @user, frequency: "0 * * * *"),
      create(:subscription, user: @user, frequency: "0 0 * * *")
    ]

    get :index, format: :json

    assert_response :success

    context = JSON.parse response.body

    assert_equal 2, context.length
  end

  test "should filter subscriptions by type" do
    page          = create :facebook_page
    subscriptions = create :subscription, user: @user, subscribable: page

    get :index, type: "twitter_search", format: :json

    assert_response :success

    context = JSON.parse response.body

    assert_empty context
  end

  test "should render a single subscription as JSON" do
    subscription = create :subscription, user: @user

    get :show, id: subscription.id, format: :json

    assert_response :success

    context = JSON.parse response.body

    assert_equal subscription.id.to_s, context["id"]
    assert_equal subscription.subscribable.id.to_s, context["page"]["id"]
    assert_equal subscription.subscribable.facebook_id, context["page"]["facebook_id"]
    assert_equal subscription.subscribable.name, context["page"]["name"]
    assert_equal subscription.frequency, context["frequency"]
    assert_equal subscription.preset, context["preset"]
    assert_equal subscription.created_at.to_time.to_s, context["created_at"].to_time.to_s
    assert_equal subscription.updated_at.to_time.to_s, context["updated_at"].to_time.to_s
  end

  test "should create a subscription for an existing page" do
    access_token = create :facebook_access_token, user: @user
    page         = create :facebook_page, facebook_id: "hyper.oslo", name: "Hyper"

    post :create, {
      format: :json,
      subscription: {
        frequency: "*/15 * * * *",
        polled: true
      },
      page: {
        facebook_id: "hyper.oslo",
        name: "Hyper"
      }
    }

    subscription = assigns :subscription

    assert_equal "*/15 * * * *", subscription.frequency
    assert_equal "hyper.oslo", subscription.subscribable.facebook_id
    assert_equal "Hyper", subscription.subscribable.name
    assert_equal @user, subscription.user

    assert_response :created
  end

  test "should create a subscription for a new page" do
    access_token = create :facebook_access_token, user: @user

    Services::Facebook::Page.any_instance.stubs(
      :synchronize
    )

    post :create, {
      format: :json,
      subscription: {
        frequency: "*/15 * * * *",
        polled: true
      },
      page: {
        facebook_id: "hyper.oslo",
        name: "Hyper"
      }
    }

    subscription = assigns :subscription

    assert_equal "*/15 * * * *", subscription.frequency
    assert_equal "hyper.oslo", subscription.subscribable.facebook_id
    assert_equal "Hyper", subscription.subscribable.name
    assert_equal @user, subscription.user

    assert_response :created
  end

  test "should create a subscription for a new twitter search" do
    access_token = create :twitter_access_token, user: @user

    Services::Twitter::Search.any_instance.stubs(
      :syncronize
    )

    post :create, {
      format: :json,
      subscription: {
        frequency: "*/15 * * * *",
        polled: true
      },
      search: {
        terms: "Ruby on Rails",
      }
    }

    subscription = assigns :subscription

    assert_equal "*/15 * * * *", subscription.frequency
    assert_equal "Ruby on Rails", subscription.subscribable.terms
    assert_equal @user, subscription.user

    assert_response :created
  end

  test "should create a subscription for a new twitter timeline" do
    access_token = create :twitter_access_token, user: @user

    Services::Twitter::Timeline.any_instance.stubs(
      :syncronize
    )

    post :create, {
      format: :json,
      subscription: {
        frequency: "*/15 * * * *",
        polled: true
      },
      timeline: {
        name: "DHH",
        screen_name: "dhh",
        picture_url: "http://dhh.jpg",
        twitter_id: "14561327"
      }
    }

    subscription = assigns :subscription

    assert_equal "*/15 * * * *", subscription.frequency
    assert_equal 14561327, subscription.subscribable.twitter_id
    assert_equal "DHH", subscription.subscribable.name
    assert_equal "dhh", subscription.subscribable.screen_name
    assert_equal "http://dhh.jpg", subscription.subscribable.picture_url
    assert_equal @user, subscription.user

    assert_response :created
  end

  test "should update a subscription by JSON" do
    subscription = create :subscription, user: @user, frequency: "0 0 * * *"

    put :update, id: subscription.id, format: :json, subscription: {
      frequency: "*/5 * * * *",
      page: "foo"
    }

    assert_response :ok

    subscription.reload

    assert_equal "*/5 * * * *", subscription.frequency
  end

  test "should destroy a subscription by JSON" do
    subscription = create :subscription, user: @user

    assert_difference "Subscription.count", -1 do
      delete :destroy, format: :json, id: subscription.id
    end

    assert_response :ok
  end
end
