# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :twitter_user, :class => 'Services::Twitter::User' do
    twitter_id 5124124141
    name { Faker::Name.name }
    screen_name { Faker::Name.name.downcase.strip.gsub(' ', '') }
  end
end
