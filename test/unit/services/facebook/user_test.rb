require 'test_helper'

class Services::Facebook::UserTest < ActiveSupport::TestCase
  test "should link to its profile" do
    user = build :facebook_user

    assert_equal "https://facebook.com/#{user.id}", user.profile_url
  end

  test "should link to its profile picture" do
    user = build :facebook_user

    assert_equal "https://graph.facebook.com/#{user.id}/picture", user.picture_url
  end
end
