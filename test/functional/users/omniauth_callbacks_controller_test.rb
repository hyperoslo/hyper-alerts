require 'test_helper'

class Users::OmniauthCallbacksControllerTest < ActionController::TestCase
  test "should authenticate with facebook" do
    OmniAuth.config.add_mock :facebook, {
      uid: "1",
      credentials: {
        token: "20vsk213vkasd13lvzi",
        expires_at: 2.weeks.from_now
      }
    }

    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["omniauth.auth"]  = OmniAuth.config.mock_auth[:facebook]

    User.
      any_instance.
      expects(
        :graph
      ).
      returns(
        stub name: "Mark Zuckerberg"
      )

    get :facebook

    assert_response :redirect

    user = User.first

    assert_equal 1, User.count

    assert_equal "Mark Zuckerberg", user.name
    assert_equal "1", user.uid

    assert_equal "20vsk213vkasd13lvzi", user.facebook_access_token.token
    assert_equal 2.weeks.from_now.iso8601, user.facebook_access_token.expires_at.iso8601
  end

  test "should authenticate with facebook for users whose access tokens never expire" do
    OmniAuth.config.add_mock :facebook, {
      uid: "1",
      credentials: {
        token: "20vsk213vkasd13lvzi",
        expires_at: nil
      }
    }

    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["omniauth.auth"]  = OmniAuth.config.mock_auth[:facebook]

    User.
      any_instance.
      expects(
        :graph
      ).
      returns(
        stub name: "Mark Zuckerberg"
      )

    get :facebook

    assert_response :redirect

    user = User.first

    assert_equal 1, User.count

    assert_equal "Mark Zuckerberg", user.name
    assert_equal "1", user.uid

    assert_equal "20vsk213vkasd13lvzi", user.facebook_access_token.token
    assert_equal true, user.facebook_access_token.infinite?
  end

  test "should authenticate with twitter and store access token" do
    user = create :user

    sign_in user

    OmniAuth.config.add_mock :twitter, {
      credentials: {
        token: "14124h1jk4hj1h4jk124-gsd345gdsgs",
        secret: "dsgsgsgwg32sdggsgs"
      }
    }

    request.env["devise.mapping"] = Devise.mappings[:user]
    request.env["omniauth.auth"]  = OmniAuth.config.mock_auth[:twitter]

    get :twitter

    assert_response :redirect

    user.reload

    assert_equal "14124h1jk4hj1h4jk124-gsd345gdsgs", user.twitter_access_token.token
    assert_equal "dsgsgsgwg32sdggsgs", user.twitter_access_token.secret
  end
end
