require 'test_helper'

class SynchronizableTest < ActiveSupport::TestCase
  class Dummy
    include Mongoid::Document
    include Concerns::Synchronizable
  end

  test "should mark itself as synchronized" do
    dummy = Dummy.new

    dummy.
      expects(
        :touch
      ).
      with(
        :synchronized_at
      )

    dummy.mark_as_synchronized
  end

  test "should determine whether it has been synchronized" do
    dummy = Dummy.new synchronized_at: 2.minutes.ago

    assert_equal true, dummy.synchronized?
  end
end
