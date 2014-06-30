# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :twitter_search, :class => 'Services::Twitter::Search' do
    terms "foo, bar"

    factory :twitter_search_with_tweets do
      ignore do
        tweets_count 5
      end

      after :create do |search, evaluator|
        FactoryGirl.create_list :twitter_tweet, evaluator.tweets_count, twitter_trackable: search
      end
    end
  end
end
