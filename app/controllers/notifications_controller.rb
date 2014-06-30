class NotificationsController < ApplicationController
  def email
    notification = JSON.parse request.raw_post

    sns = Fog::AWS::SNS.new aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"], aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"]

    # The payload upon confirming a subscription has key "Type", whereas notifications have key "notificationType".
    case notification["Type"] || notification["notificationType"]
    when "SubscriptionConfirmation"
      sns.confirm_subscription notification["TopicArn"], notification["Token"]

      render nothing: true, status: :ok
    when "Bounce"
      notification["bounce"]["bouncedRecipients"].each do |recipient|
        User.where(email: recipient["emailAddress"]).update_all bouncing_since: Time.now
      end
      render nothing: true, status: :ok
    else
      render nothing: true, status: :bad_request
    end
  end
end
