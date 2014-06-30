require 'test_helper'

class SchedulableTest < ActiveSupport::TestCase
  class Dummy
    include Mongoid::Document
    include Concerns::Schedulable
  end

  test "should schedule itself" do
    dummy = Dummy.new

    dummy.expects :enqueue

    dummy.schedule

    assert_equal Time.now, dummy.scheduled_at
  end

  test "should deschedule itself" do
    dummy = Dummy.new

    dummy.deschedule

    assert_equal nil, dummy.scheduled_at
  end

  test "should reschedule itself" do
    dummy = Dummy.new

    dummy.expects :schedule

    dummy.reschedule
  end

  test "should determine whether it's scheduled" do
    dummy = Dummy.new scheduled_at: 2.minutes.ago

    assert_equal true, dummy.scheduled?
  end
end
