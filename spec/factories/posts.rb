FactoryGirl.define do
  factory :post do
    title { Faker::Lorem.words(4)}
    body { Faker::Lorem.paragraphs(3,false) }
    user_id nil
  end
end