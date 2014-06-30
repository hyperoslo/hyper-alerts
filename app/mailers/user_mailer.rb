class UserMailer < ActionMailer::Base
  # Remind the user to renew his/her access token.
  def access_token_renewal_reminder user
    @user = user

    mail to: user.email, subject: "Please renew your access token"
  end

  # Notify the user that his/her access token has expired.
  def access_token_expired_email user
    @user = user

    mail to: user.email, subject: "Your access token has expired"
  end
end
