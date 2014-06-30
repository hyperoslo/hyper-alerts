# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    provider "facebook"
    uid { rand 20 }

    after :build do |user, evaluator|
      user.twitter_access_token = FactoryGirl.build :twitter_access_token, user: user
    end

    before :create do |user|
      user.skip_confirmation!
    end
  end
end
