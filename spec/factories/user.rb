FactoryBot.define do
  factory :user do
    company

    first_name { "Test" }
    last_name { "User" }
    sequence(:email) { |n| "#{n}@example.com" }

    deletable { true }
  end
end
