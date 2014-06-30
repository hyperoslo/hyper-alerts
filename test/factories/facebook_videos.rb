# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :facebook_video, :class => 'Services::Facebook::Video' do
    name { "Example video" }
    picture { "http://example.org/video.jpg" }
    source { "http://example.org/video.m4v" }
    updated_at { 2.weeks.ago }
    created_at { 2.weeks.ago }

    factory :facebook_video_with_comments do
      ignore do
        comments_count 5
      end

      after :build do |video, evaluator|
        FactoryGirl.build_list :facebook_comment, evaluator.comments_count, commentable: video
      end
    end
  end
end
