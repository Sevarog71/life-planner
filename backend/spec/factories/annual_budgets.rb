FactoryBot.define do
  factory :annual_budget do
    sequence(:year) { |n| 2025 + n }
    annual_income { 5000000 }
    annual_expense { 3000000 }
    notes { "テスト予算" }
  end
end
