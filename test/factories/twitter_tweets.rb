# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :twitter_tweet, :class => 'Services::Twitter::Tweet' do
    twitter_id 12415151451
    text { Faker::Lorem.sentence }
    created_at { Time.now }
    association :author, factory: :twitter_user, strategy: :build
  end
end
