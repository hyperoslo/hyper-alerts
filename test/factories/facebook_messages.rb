# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :facebook_message, :class => 'Services::Facebook::Message' do
    message { Faker::Lorem.sentence }
    created_at { Time.now }
    association :author, factory: :facebook_user, strategy: :build
  end
end
