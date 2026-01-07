class OptimizeLifeEventsTable < ActiveRecord::Migration[7.1]
  def change
    # estimated_costのprecisionとscale指定
    change_column :life_events, :estimated_cost, :decimal, precision: 12, scale: 2

    # インデックスの追加
    add_index :life_events, :scheduled_date, comment: 'ソートと検索用'
    add_index :life_events, :event_type, comment: 'フィルタリング用'
  end
end
