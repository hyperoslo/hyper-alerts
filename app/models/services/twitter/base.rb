class Services::Twitter::Base
  include Mongoid::Document
  include Mongoid::Paranoia

  # Determine whether there's anything new for the given subscription
  #
  # subscription - A Subscription instance.
  #
  # Returns a Boolean.
  def updates_for? subscription
    tweets.where(:created_at.gt => (subscription.notified_at || subscription.created_at)).any?
  end
end
