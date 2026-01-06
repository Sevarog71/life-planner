FactoryBot.define do
  factory :life_event do
    event_type { "MyString" }
    name { "MyString" }
    scheduled_date { "2026-01-06" }
    estimated_cost { "9.99" }
    notes { "MyText" }
  end
end
