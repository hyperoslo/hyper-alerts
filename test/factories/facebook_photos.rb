# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :facebook_photo, :class => 'Services::Facebook::Photo' do
    link { "http://example.org/image.html" }
    source { "http://example.org/image.jpg" }
    created_at { 2.weeks.ago }

    factory :facebook_photo_with_comments do
      ignore do
        comments_count 5
      end

      after :build do |photo, evaluator|
        FactoryGirl.build_list :facebook_comment, evaluator.comments_count, commentable: photo
      end
    end
  end
end
