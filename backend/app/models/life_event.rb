class LifeEvent < ApplicationRecord
  validates :name, presence: true
  validates :event_type, presence: true
  validates :scheduled_date, presence: true
  validates :estimated_cost, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # イベントタイプの定数
  EVENT_TYPES = %w[
    marriage
    birth
    house_purchase
    car_purchase
    education
    retirement
    other
  ].freeze

  validates :event_type, inclusion: { in: EVENT_TYPES }, allow_blank: true
end
