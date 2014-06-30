# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :subscription do
    user
    frequency "*/15 * * * *"
    polled true
    pushed false
    scope ["posts", "comments"]
    association :subscribable, factory: :facebook_page
  end
end
