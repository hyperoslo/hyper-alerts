object @subscription

node :id do |subscription|
  subscription.id.to_s
end

attribute :frequency
attribute :preset
attribute :scope
attribute :created_at
attribute :notified_at
attribute :updated_at
attribute :polled
attribute :pushed

node :type do |subscription|
  case subscription.subscribable.class
    when Services::Facebook::Page
      "facebook"
    when Services::Twitter::Search
      "twitter_search"
    when Services::Twitter::Timeline
      "twitter_timeline"
  end
end

child :subscribable do |subscribable|
  extends "services/facebook/pages/show" if subscribable.is_a? Services::Facebook::Page
  extends "services/twitter/searches/show" if subscribable.is_a? Services::Twitter::Search
  extends "services/twitter/timelines/show" if subscribable.is_a? Services::Twitter::Timeline
end
