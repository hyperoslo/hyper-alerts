# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :facebook_access_token, :class => 'Services::Facebook::AccessToken' do
    token { SecureRandom.hex 16 }
    expires_at { 2.weeks.from_now }
    user
  end
end
