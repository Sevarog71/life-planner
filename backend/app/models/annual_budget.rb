class AnnualBudget < ApplicationRecord
  validates :year, presence: true, uniqueness: true
  validates :year, numericality: { only_integer: true, greater_than: 1900, less_than: 2200 }
  validates :annual_income, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :annual_expense, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # 年度でソート
  scope :ordered, -> { order(year: :asc) }
end
