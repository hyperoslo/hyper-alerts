require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should render a form to edit a user" do
    user  = create :user
    token = create :facebook_access_token, user: user

    User.
      any_instance.
      expects(
        :graph
      ).
      returns(
        stub permissions: []
      )

    sign_in user

    get :edit, id: user.id

    assert_response :ok
  end

  test "should update a user" do
    user = create :user

    sign_in user

    put :update, id: user.id, user: {
      email: "user@domain.tld"
    }

    user.reload

    assert_redirected_to edit_user_url user

    assert_equal "user@domain.tld", user.unconfirmed_email
  end

  test "should not allow editing other users" do
    user         = create :user
    another_user = create :user

    sign_in user

    put :update, id: another_user.id, user: {
      email: "user@domain.tld"
    }

    assert_response :forbidden
  end


  test "should not allow destroying other users" do
    user         = create :user
    another_user = create :user

    sign_in user

    delete :destroy, id: another_user.id

    assert_response :forbidden
  end

  test "should destroy a user" do
    user = create :user

    sign_in user

    assert_difference "User.count", -1 do
      delete :destroy, id: user.id
    end

    assert_redirected_to :root
  end

  test "should verify whether the configured time zone differs from the actual time zone" do
    user = create :user, time_zone_name: "Europe/Stockholm"

    sign_in user

    get :time_zone_difference, id: "me", time_zone_name: "America/New_York"

    assert_equal "-6", response.body
  end
end
