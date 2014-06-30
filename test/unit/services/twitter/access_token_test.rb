require 'test_helper'

class Services::Twitter::AccessTokenTest < ActiveSupport::TestCase
  setup do
    Timecop.freeze
  end

  teardown do
    Timecop.return
  end

  test "should invalidate" do
    access_token = create :twitter_access_token

    access_token.invalidate

    assert ActionMailer::Base.deliveries.any?
    assert_equal true, access_token.is_invalid
  end

  test "should renew itself" do
    access_token = create :twitter_access_token

    new_token      = "<access token>"
    new_secret     = "<access token secret>"

    access_token.renew new_token, new_secret

    assert_equal new_token, access_token.token
    assert_equal new_secret, access_token.secret
  end
end
