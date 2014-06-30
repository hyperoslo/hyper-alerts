# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :facebook_user, :class => 'Services::Facebook::User' do
    name { Faker::Name.name }
  end
end
