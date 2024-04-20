FactoryBot.define do
  factory :user do
    email { Faker::Internet.unique.email }
    password { 'a12345678' }
  end
end
