FactoryBot.define do
  factory :life_event do
    event_type { "car_purchase" }
    name { "テストイベント" }
    scheduled_date { Date.new(2025, 6, 15) }
    estimated_cost { 500000 }
    notes { "テストメモ" }
  end
end
