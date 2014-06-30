# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :facebook_page, :class => 'Services::Facebook::Page' do
    name { Faker::Company.name }
    facebook_id { rand 100000000..999999999 }
    likes { rand 100...500 }

    factory :facebook_page_with_posts do
      ignore do
        posts_count 5
      end

      after :create do |page, evaluator|
        FactoryGirl.create_list :facebook_post, evaluator.posts_count, page: page
      end
    end

    factory :facebook_page_with_posts_and_comments do
      ignore do
        posts_count 5
      end

      after :create do |page, evaluator|
        FactoryGirl.create_list :facebook_post_with_comments, evaluator.posts_count, page: page
      end
    end
  end
end
