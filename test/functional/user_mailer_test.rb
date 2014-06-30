require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "access token renewal reminder" do
    user = create :user

    email = UserMailer.access_token_renewal_reminder(user).deliver

    assert_equal [user.email], email.to
    assert_match /renew your access token/, email.encoded
  end

  test "access token expired email" do
    user = create :user

    email = UserMailer.access_token_expired_email(user).deliver

    assert_equal [user.email], email.to
    assert_match /has expired/, email.encoded
  end
end
