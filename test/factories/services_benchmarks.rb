# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :services_benchmark, :class => 'Services::Benchmark' do
    start "2013-09-12 15:28:26"
    stop "2013-09-12 15:28:26"
  end
end
