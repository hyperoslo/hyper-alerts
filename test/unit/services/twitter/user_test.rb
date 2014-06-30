require 'test_helper'

class Services::Twitter::UserTest < ActiveSupport::TestCase

  test "should not save without a twitter id" do
    user = build :twitter_user, twitter_id: nil

    assert_equal false, user.valid?
  end

  test "should not save without a screen name" do
    user = build :twitter_user, screen_name: nil

    assert_equal false, user.valid?
  end
end
