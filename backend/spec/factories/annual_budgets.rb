FactoryBot.define do
  factory :annual_budget do
    year { 1 }
    annual_income { "9.99" }
    annual_expense { "9.99" }
    notes { "MyText" }
  end
end
