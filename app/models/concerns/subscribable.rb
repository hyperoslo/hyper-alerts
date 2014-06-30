# Subscribable models receive subscriptions.
module Concerns::Subscribable
  extend ActiveSupport::Concern

  included do
    has_many :subscriptions, as: :subscribable, dependent: :destroy
  end

  # Return an array of subscribers.
  def subscribers
    subscriptions.map { |s| s.user }
  end
end
