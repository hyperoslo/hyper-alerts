include MailerHelper

class SubscriptionMailer < ActionMailer::Base
  helper do
    # Determine whether the given item is new to the
    # subscription.
    #
    # item - Any object that responds to "created_at".
    #
    # Returns a Boolean.
    def new? item
      item.created_at > (@subscription.notified_at || @subscription.created_at)
    end
  end

  def facebook subscription
    @subscription = subscription
    @user         = subscription.user
    @page         = subscription.subscribable

    updates = @page.updates_for @subscription

    @posts    = updates[:posts] || []
    @photos   = updates[:photos] || []
    @videos   = updates[:videos] || []
    @messages = updates[:messages] || []

    posts = @posts + @photos + @videos

    comments = (
      posts.map { |p| p.comments }.flatten +
      posts.map { |p| p.comments }.flatten.map { |c| c.comments }.flatten
    )

    new_posts    = posts.count { |post| post.created_at > (@subscription.notified_at || @subscription.created_at) }
    new_comments = comments.count { |comment| comment.created_at > (@subscription.notified_at || @subscription.created_at) }

    if @subscription.scope.include? "messages"
      @messages = @page.messages.where :created_at.gt => (@subscription.notified_at || @subscription.created_at)
    else
      @messages = []
    end

    Time.use_zone @user.time_zone do
      mail to: @user.email, subject: "[#{@page}] #{new_posts} new posts and #{new_comments} new comments"
    end
  end

  def twitter_search subscription
    @subscription = subscription
    @user         = subscription.user
    @search       = subscription.subscribable

    @tweets = @search.tweets.where :created_at.gt => (@subscription.notified_at || @subscription.created_at)

    Time.use_zone @user.time_zone do
      mail to: @user.email, subject: "[#{@search}] #{@tweets.count} new tweets"
    end
  end

  def twitter_timeline subscription
    @subscription = subscription
    @user         = subscription.user
    @timeline     = subscription.subscribable

    @tweets = @timeline.tweets.where :created_at.gt => (@subscription.notified_at || @subscription.created_at)

    Time.use_zone @user.time_zone do
      mail to: @user.email, subject: "[#{@timeline}] #{@tweets.count} new tweets"
    end
  end
end
