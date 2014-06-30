# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :twitter_access_token, :class => 'Services::Twitter::AccessToken' do
    token { SecureRandom.hex 16 }
    secret { SecureRandom.hex 16 }
    user
  end
end
