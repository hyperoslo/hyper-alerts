class UserMailerPreview < MailView

  def access_token_renewal_reminder
    mail = UserMailer.access_token_renewal_reminder User.first
  end

  def access_token_expired_email
    mail = UserMailer.access_token_expired_email User.first
  end
end
