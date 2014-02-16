FactoryGirl.define do
  factory :authentication do
    uid       Faker::Lorem.characters(4)
    token     "#{Faker::Lorem.characters(4)}-#{Faker::Lorem.characters(20)}"
    secret    Faker::Lorem.characters(20)
  
    factory :twitter_authentication do
      provider  "twitter"
    end

    trait :with_user do
      user
    end
  end
end
