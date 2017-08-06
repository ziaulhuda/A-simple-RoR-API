FactoryGirl.define do
  factory :comment do
    body { Faker::Lorem.paragraphs(3,false) }
    post_id nil
    user_id nil
  end
end