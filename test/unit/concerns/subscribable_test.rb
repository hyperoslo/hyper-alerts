require 'test_helper'

class SubscribableTest < ActiveSupport::TestCase
  class Dummy
    include Mongoid::Document
    include Concerns::Schedulable
    include Concerns::Synchronizable
    include Concerns::Subscribable
  end

  test "should find its subscribers" do
    user         = build :user
    subscription = build :subscription, user: user

    dummy = Dummy.new subscriptions: [subscription]

    assert_equal [user], dummy.subscribers
  end

  test "should delete its subscriptions upon deletion" do
    subscription = build :subscription, frequency: "*/15 * * * *"

    dummy = Dummy.new subscriptions: [subscription]

    dummy.destroy

    assert_equal true, subscription.destroyed?
  end
end
