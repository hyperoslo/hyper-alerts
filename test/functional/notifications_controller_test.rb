require 'test_helper'

class NotificationsControllerTest < ActionController::TestCase
  test "it should confirm subscription requests from Amazon SNS" do
    data = fixture "amazon/sns/subscription_confirmation.json"

    sns = mock

    sns.
      expects(
        :confirm_subscription
      ).
      with(
        "arn:aws:sns:us-east-1:123456789012:MyTopic",
        "2336412f37fb687f5d51e6e241d09c805a5a57b30d712f794cc5f6a988666d92768dd60a747ba6f3beb71854e285d6ad" +
        "02428b09ceece29417f1f02d609c582afbacc99c583a916b9981dd2728f4ae6fdb82efd087cc3b7849e05798d2d2785c" +
        "03b0879594eeac82c01f235d0e717736"
      )

    Fog::AWS::SNS.
      expects(
        :new
      ).
      returns(
        sns
      )

    @request.env['RAW_POST_DATA'] = data
    post :email, format: :text

    assert_response :success
  end

  test "it should flag users whose e-mail addresses are bouncing" do
    user = create :user, email: "username@example.com", bouncing_since: nil

    data = fixture "amazon/sns/bounce_notification.json"

    Timecop.freeze Time.now do
      @request.env['RAW_POST_DATA'] = data
      post :email, format: :text

      assert_equal Time.now.to_i, user.reload.bouncing_since.to_i
      assert_response :success
    end
  end
end
