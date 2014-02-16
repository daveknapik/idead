FactoryGirl.define do
  factory :user do
    email     Faker::Internet.email
    password  Faker::Internet.password

    factory :user_with_authentications do
      ignore do
        authentications_count 1
      end

      after(:create) do |user, evaluator|
        create_list(:authentication, evaluator.authentications_count, user: user)
      end
    end
  end
end
