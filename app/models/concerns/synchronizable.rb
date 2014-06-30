# Synchronizable models gain methods for for determining whether they
# are being synchronized and when they were last synchronized.
module Concerns::Synchronizable
  extend ActiveSupport::Concern

  included do
    field :synchronized_at, type: Time
  end

  # Determine whether whether this model has been synchronized.
  def synchronized?
    !!synchronized_at
  end

  # Mark the model as synchronized.
  def mark_as_synchronized
    touch :synchronized_at
  end
end
