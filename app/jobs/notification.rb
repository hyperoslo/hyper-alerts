class Notification
  include Sidekiq::Worker

  sidekiq_retries_exhausted do |msg|
    deactivate msg["args"].first
  end

  # Configure to retry every 10 minutes for 50 minutes.
  sidekiq_options retry: 5

  sidekiq_retry_in do |count|
    10 * 60 * (count + 1)
  end

  # Send a notification.
  #
  # id - A String identifying a Subscription.
  def perform id
    @subscription = Subscription.find id

    if @subscription.due?
      Services::Benchmark.measure benchmarkable: @subscription.subscribable do
        case @subscription.subscribable.class
          when Services::Facebook::Page then synchronize_facebook_page @subscription.subscribable
          when Services::Twitter::Timeline then synchronize_twitter_timeline @subscription.subscribable
          when Services::Twitter::Search then synchronize_twitter_search @subscription.subscribable
        end
      end

      # If the subscription's subscribable no longer exists or can no longer be accessed,
      # the subscription will have been destroyed.
      return if @subscription.destroyed?

      @subscription.notify
    end

    @subscription.deschedule
    # If another subscription for the same subject was processed after the subscription was enqueued
    # and the subject was destroyed, both subscriptions would be deleted from the database and the worker
    # would raise an error upon attempting to process it.
    #
    # One might argue that it would be more appropriate to simply deschedule other subscriptions,
    # but Mike Perham of Sidekiq disagrees and has not facilitated for doing so:
    #
    # https://github.com/mperham/sidekiq/pull/257
    rescue Mongoid::Errors::DocumentNotFound
  end

  private

  # Deactivate the given subscription.
  #
  # id - A String identifying a Subscription.
  def deactivate id
    subscription = Subscription.find id
    subscription.deactivate
  end

  # Synchronize the given Facebook page.
  #
  # page - A Services::Facebook::Page instance.
  def synchronize_facebook_page page
    access_token = @subscription.user.facebook_access_token

    scope = [:name, :likes]

    if @subscription.scope.include? "posts"
      scope += [:posts, :photos, :videos]
    end

    if @subscription.scope.include? "messages"
      scope += [:messages]
    end

    page.synchronize access_token.token, only: scope
  rescue Services::Facebook::AccessToken::Invalid
    access_token.expire
  end

  # Synchronize the given Twitter search.
  #
  # search - A Services::Twitter::Search instance.
  def synchronize_twitter_search search
    access_token = @subscription.user.twitter_access_token

    search.synchronize access_token.token, access_token.secret
  rescue Services::Twitter::AccessToken::Invalid
    access_token.invalidate
    @subscription.prohibit
  end

  # Synchronize the given Twitter timeline.
  #
  # search - A Services::Twitter::Timeline instance.
  def synchronize_twitter_timeline timeline
    access_token = @subscription.user.twitter_access_token

    timeline.synchronize access_token.token, access_token.secret
  rescue Services::Twitter::AccessToken::Invalid
    access_token.invalidate
    @subscription.prohibit
  end
end
