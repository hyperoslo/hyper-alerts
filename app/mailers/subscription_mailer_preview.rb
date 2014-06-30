class SubscriptionMailerPreview < MailView

  def facebook
    SubscriptionMailer.facebook User.first.subscriptions.facebook.last
  end

  def twitter_search
    SubscriptionMailer.twitter_search User.first.subscriptions.twitter_search.last
  end

  def twitter_timeline
    SubscriptionMailer.twitter_timeline User.first.subscriptions.twitter_timeline.last
  end

end
