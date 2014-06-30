class Subscription
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paranoia

  include Concerns::Schedulable

  default_scope where deactivated_at: nil

  scope :polled, where(polled: true)
  scope :pushed, where(pushed: true)

  # An Array of Strings describing the scope of the subscription (e.g. whether it should include comments).
  field :scope, type: Array, default: []

  # A String describing the polling frequency of the subscription, represented by a cron expression.
  field :frequency, type: String

  # A Boolean describing whether the subscription polls for changes.
  field :polled, type: Boolean, default: false

  # A Boolean describing whether the subscription receives pushed changes.
  field :pushed, type: Boolean, default: false

  # A String describing the frequency preset.
  field :preset, type: String

  # A Time instance describing when the subscriber was notified of changes.
  field :notified_at, type: Time

  # A Time instance describing when the subscription was deactivated.
  field :deactivated_at, type: Time

  # An instance of something subscribable (e.g. Services::Facebook::Page).
  belongs_to :subscribable, polymorphic: true, index: true

  # A User instance.
  belongs_to :user, index: true

  validates :user, presence: true
  validates :subscribable, presence: true
  validates :frequency, presence: true, if: :polled?

  validate :frequency_must_be_a_cron_expression
  validate :user_must_have_a_twitter_access_token

  attr_accessible :frequency, :preset, :pushed, :polled, :scope

  # Mongoid insists on setting fields of type Array to nil if they're empty. I disagree
  # with this behaviour because it causes NoMethodErrors on nil all over the place.
  #
  # https://github.com/mongoid/mongoid/issues/442
  before_save do |subscription|
    subscription.scope = [] if subscription.scope.nil?
  end

  # Deactivate the subscription.
  def deactivate
    touch :deactivated_at
  end

  # Activate the subscription.
  def activate
    update_attribute :deactivated_at, nil
  end

  # Determine whether the subscription is deactivated.
  def deactivated?
    !!deactivated_at
  end

  # Destroy the subscription and notify its recipient that he/she
  # no longer has access to it.
  #
  # TODO: Actually notify the recipient.
  def prohibit
    destroy
  end

  # Determine whether the subscriber is due for an update.
  def due?
    if user.email.blank?
      return false
    end

    if subscribable.is_a? Services::Facebook::Page
      return false if user.facebook_access_token.expired?
    end

    if pushed?
      return true
    else
      return last_notification_due_at > (notified_at || created_at)
    end
  end

  # Determine when the subscriber should have been notified.
  #
  # Returns a Time instance.
  def last_notification_due_at
    cron.last.in_time_zone user.time_zone if frequency
  end

  # Determine when the subscriber should be notified.
  #
  # Returns a Time instance.
  def next_notification_due_at
    cron.next.in_time_zone user.time_zone if frequency
  end

  # Determine how long until the subscriber should be notified.
  #
  # Returns an Integer describing seconds.
  def next_notification_due_in
    next_notification_due_at - Time.zone.now
  end

  # Determine whether the subscriber has been notified.
  #
  # Returns a Boolean.
  def notified?
    !!notified_at
  end

  # Notify the subscriber of new items in this subscription.
  def notify
    mailer = SubscriptionMailer

    if updates?
      mail = case subscribable.class
        when Services::Facebook::Page then mailer.facebook self
        when Services::Twitter::Search then mailer.twitter_search self
        when Services::Twitter::Timeline then mailer.twitter_timeline self
      end

      mail.deliver
    end

    touch :notified_at
  end

  # Determine whether there's anything new to this subscription.
  #
  # Returns a Boolean.
  def updates?
    subscribable.updates_for? self
  end

  # Enqueue a notification for the subscription.
  def enqueue
    Notification.perform_async id.to_s
  end

  # Subscribe to real-time updates for the subscription.
  #
  # Note: This feature is exclusive to Facebook subscriptions.
  def subscribe_to_real_time_updates
    graph = user.graph lazy: true

    page = graph.accounts.find do |page|
      page.identifier == subscribable.facebook_id
    end or raise "The user is not an administrator of #{subscribable.name}"

    page.tab! app_id: Rails.configuration.facebook_application_id
  end

  # Unsubscribe from real-time updates for the subscription.
  #
  # Note: This feature is exclusive to Facebook subscriptions.
  def unsubscribe_from_real_time_updates
    # It is currently impossible to remove applications installed on Facebook Pages due
    # to a bug in the Graph API:
    #
    # https://developers.facebook.com/bugs/503381706394259
  end

  # Determine when the subscription was either notified or created.
  def notified_or_created_at
    notified_at || created_at
  end

  def to_s
    "#{user}'s subscription to #{subscribable}"
  end

  private

  # Validate that the subscription's frequency must be a GNU cron-compatible expression.
  def frequency_must_be_a_cron_expression
    if frequency.present?
      CronParser.new(frequency).next
    end
  rescue RuntimeError => exception
    errors.add :frequency, exception.message
  end

  # Validate that the subscriber must have let us a Twitter access token to create Twitter subscriptions.
  def user_must_have_a_twitter_access_token
    if subscribable.kind_of? Services::Twitter::Base
      errors.add :base, "You must authorize Hyper Alerts to access Twitter" unless user.twitter_access_token
    end
  end

  # Parse the cron expression.
  #
  # Returns a CronParser instance.
  def cron
    CronParser.new frequency, user.time_zone
  end
end
