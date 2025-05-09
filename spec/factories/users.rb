# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    first_name { "Ryan" }
    last_name { "Bartolome" }
    birthday { "1984-06-18" }
    gender { "male" }
    address { "Manila, Philippines" }
    status { "pending" }
    role { :trader }
    sequence(:slug) { |n| "user-#{n}" }
    confirmed_at { Time.current }

    trait :with_portfolio do
      after(:create) do |user|
        create(:portfolio, user: user)
      end
    end

    trait :admin do
      role { :admin }
      status { :approved }
    end

    trait :approved do
      status { :approved }
    end

    trait :with_incomplete_profile do
      first_name { nil }
      last_name { nil }
      birthday { nil }
      gender { nil }
      address { nil }
    end
  end
end