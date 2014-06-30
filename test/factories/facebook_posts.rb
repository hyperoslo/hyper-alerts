# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :facebook_post, :class => 'Services::Facebook::Post' do
    message { Faker::Lorem.sentence }
    icon { "http://facebook.com/icon.png" }
    created_at { Time.now }
    updated_at { Time.now }
    association :author, factory: :facebook_user, strategy: :build

    factory :facebook_post_with_comments do
      ignore do
        comments_count 5
      end

      after :build do |post, evaluator|
        FactoryGirl.build_list :facebook_comment, evaluator.comments_count, commentable: post
      end
    end
  end
end
