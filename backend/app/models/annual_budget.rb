class AnnualBudget < ApplicationRecord
  validates :year, presence: true, uniqueness: true
  validates :year, numericality: { only_integer: true, greater_than: 1900, less_than: 2200 }
  validates :annual_income, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :annual_expense, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # スコープ
  # 年度でソート
  scope :ordered, -> { order(year: :asc) }

  # 直近n年分
  scope :recent, ->(n = 5) { order(year: :desc).limit(n) }

  # 黒字の年
  scope :surplus, -> { where('annual_income > annual_expense') }

  # 赤字の年
  scope :deficit, -> { where('annual_income < annual_expense') }

  # 年範囲指定
  scope :year_range, ->(start_year, end_year) { where(year: start_year..end_year).ordered }

  # インスタンスメソッド
  # 純収入計算（Blueprintから移動）
  def net_income
    return 0 unless annual_income && annual_expense
    annual_income - annual_expense
  end

  # 黒字か判定
  def surplus?
    net_income > 0
  end

  # 赤字か判定
  def deficit?
    net_income < 0
  end

  # 収支均衡か判定
  def balanced?
    net_income == 0
  end

  # 貯蓄率計算（収入に対する貯蓄の割合）
  def savings_rate
    return 0 if annual_income.nil? || annual_income.zero?
    (net_income / annual_income * 100).round(2)
  end

  # フォーマットされた純収入表示
  def formatted_net_income
    amount = net_income
    sign = amount >= 0 ? '+' : ''
    "#{sign}¥#{amount.to_i.abs.to_s.reverse.scan(/\d{1,3}/).join(',').reverse}"
  end
end
