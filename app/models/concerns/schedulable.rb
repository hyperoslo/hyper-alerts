# Schedulable models receive methods for scheduling, descheduling and rescheduling
# a given job as defined by the "enqueue" method, which must be implemented.
module Concerns::Schedulable
  extend ActiveSupport::Concern

  included do
    field :scheduled_at, type: Time
  end

  def schedule
    set :scheduled_at, Time.now

    enqueue
  end

  def deschedule
    set :scheduled_at, nil
  end

  def reschedule
    deschedule
    schedule
  end

  def scheduled?
    !!scheduled_at
  end
end
