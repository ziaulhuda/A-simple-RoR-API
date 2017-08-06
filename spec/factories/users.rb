FactoryGirl.define do
  factory :user do
    name { Faker::Lorem.words(2)}
    email { Faker::Internet.unique.email }
    password '12345678'
  end
end