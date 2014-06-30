# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :twitter_timeline, :class => 'Services::Twitter::Timeline' do
    twitter_id 123
    name "DHH"
    screen_name "dhh"
    picture_url "https://si0.twimg.com/profile_images/2556368541/alng5gtlmjhrdlr3qxqv_normal.jpeg"

    factory :twitter_timeline_with_tweets do
      ignore do
        tweets_count 5
      end

      after :create do |timeline, evaluator|
        FactoryGirl.create_list :twitter_tweet, evaluator.tweets_count, twitter_trackable: timeline
      end
    end
  end
end
