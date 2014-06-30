module MailerHelper
  def current_ad

    Ad.where(
      :active_at.lte => Time.current,
      :expires_at.gte => Time.current
    ).first

   end
end
