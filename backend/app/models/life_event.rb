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

  # イベントタイプの日本語名マッピング
  EVENT_TYPE_NAMES = {
    'marriage' => '結婚',
    'birth' => '出産',
    'house_purchase' => '住宅購入',
    'car_purchase' => '車購入',
    'education' => '教育',
    'retirement' => '退職',
    'other' => 'その他'
  }.freeze

  validates :event_type, inclusion: { in: EVENT_TYPES }, allow_blank: true

  # スコープ
  # 未来のイベント
  scope :upcoming, -> { where('scheduled_date >= ?', Date.today).order(scheduled_date: :asc) }

  # 過去のイベント
  scope :past, -> { where('scheduled_date < ?', Date.today).order(scheduled_date: :desc) }

  # 特定タイプのイベント
  scope :by_type, ->(type) { where(event_type: type) }

  # 特定年のイベント
  scope :in_year, ->(year) { where('EXTRACT(YEAR FROM scheduled_date) = ?', year) }

  # 年範囲のイベント
  scope :in_year_range, ->(start_year, end_year) {
    where('EXTRACT(YEAR FROM scheduled_date) BETWEEN ? AND ?', start_year, end_year)
  }

  # コストが設定されているイベント
  scope :with_cost, -> { where.not(estimated_cost: nil) }

  # 日付でソート（デフォルト昇順）
  scope :ordered, -> { order(scheduled_date: :asc) }

  # インスタンスメソッド
  # イベントまでの日数
  def days_until
    (scheduled_date - Date.today).to_i
  end

  # 未来のイベントか判定
  def upcoming?
    scheduled_date >= Date.today
  end

  # 過去のイベントか判定
  def past?
    !upcoming?
  end

  # コストがあるか判定
  def has_cost?
    estimated_cost.present? && estimated_cost > 0
  end

  # フォーマットされた金額表示（日本円）
  def formatted_cost
    return "未設定" unless estimated_cost
    "¥#{estimated_cost.to_i.to_s.reverse.scan(/\d{1,3}/).join(',').reverse}"
  end

  # イベントタイプの日本語名
  def event_type_name
    EVENT_TYPE_NAMES[event_type] || event_type
  end
end
