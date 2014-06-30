# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :facebook_comment, :class => 'Services::Facebook::Comment' do
    message { Faker::Lorem.sentence }
    created_at { 2.weeks.ago }
    association :author, factory: :facebook_user, strategy: :build
  end
end
