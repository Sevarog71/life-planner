# 既存データをクリア（開発環境のみ）
if Rails.env.development?
  puts "既存データをクリア中..."
  LifeEvent.destroy_all
  AnnualBudget.destroy_all
  puts "クリア完了"
end

puts "\n========================================="
puts "ライフイベントのサンプルデータを作成中..."
puts "=========================================\n"

life_events_data = [
  {
    name: "結婚式・披露宴",
    event_type: "marriage",
    scheduled_date: Date.new(2025, 6, 15),
    estimated_cost: 3_500_000,
    notes: "結婚式、披露宴、新婚旅行の費用合計"
  },
  {
    name: "第一子出産",
    event_type: "birth",
    scheduled_date: Date.new(2026, 10, 1),
    estimated_cost: 500_000,
    notes: "出産費用、ベビー用品購入"
  },
  {
    name: "マイホーム購入（頭金）",
    event_type: "house_purchase",
    scheduled_date: Date.new(2028, 4, 1),
    estimated_cost: 8_000_000,
    notes: "頭金（物件価格の20%想定）"
  },
  {
    name: "第二子出産",
    event_type: "birth",
    scheduled_date: Date.new(2029, 5, 15),
    estimated_cost: 400_000,
    notes: "第二子の出産費用"
  },
  {
    name: "車の買い替え（ファミリーカー）",
    event_type: "car_purchase",
    scheduled_date: Date.new(2030, 3, 1),
    estimated_cost: 3_000_000,
    notes: "7人乗りミニバン購入予定"
  },
  {
    name: "長男の小学校入学",
    event_type: "education",
    scheduled_date: Date.new(2033, 4, 1),
    estimated_cost: 300_000,
    notes: "ランドセル、制服、入学準備費用"
  },
  {
    name: "長女の小学校入学",
    event_type: "education",
    scheduled_date: Date.new(2036, 4, 1),
    estimated_cost: 300_000,
    notes: "ランドセル、制服、入学準備費用"
  },
  {
    name: "長男の中学校入学",
    event_type: "education",
    scheduled_date: Date.new(2039, 4, 1),
    estimated_cost: 500_000,
    notes: "制服、自転車、部活用品等"
  },
  {
    name: "長男の高校入学",
    event_type: "education",
    scheduled_date: Date.new(2042, 4, 1),
    estimated_cost: 500_000,
    notes: "入学金、制服、教材費"
  },
  {
    name: "長男の大学入学",
    event_type: "education",
    scheduled_date: Date.new(2045, 4, 1),
    estimated_cost: 2_000_000,
    notes: "入学金、初年度授業料、一人暮らし準備"
  },
  {
    name: "定年退職",
    event_type: "retirement",
    scheduled_date: Date.new(2055, 3, 31),
    estimated_cost: nil,
    notes: "65歳で定年退職予定"
  }
]

life_events_data.each do |data|
  event = LifeEvent.create!(data)
  puts "✓ #{event.name} (#{event.scheduled_date.strftime('%Y年%m月%d日')})"
end

puts "\n作成完了: #{LifeEvent.count}件のライフイベント\n"

puts "\n========================================="
puts "年次予算のサンプルデータを作成中..."
puts "=========================================\n"

current_year = Date.today.year

budgets_data = [
  {
    year: current_year,
    annual_income: 5_000_000,
    annual_expense: 4_200_000,
    notes: "現在の収支状況（実績ベース）"
  },
  {
    year: current_year + 1,
    annual_income: 5_200_000,
    annual_expense: 4_500_000,
    notes: "昇給見込み（3-5%）"
  },
  {
    year: current_year + 2,
    annual_income: 5_400_000,
    annual_expense: 5_000_000,
    notes: "子供誕生により支出増"
  },
  {
    year: current_year + 3,
    annual_income: 5_600_000,
    annual_expense: 5_200_000,
    notes: ""
  },
  {
    year: current_year + 4,
    annual_income: 5_800_000,
    annual_expense: 6_800_000,
    notes: "住宅ローン返済開始（月12万円想定）"
  },
  {
    year: current_year + 5,
    annual_income: 6_000_000,
    annual_expense: 7_000_000,
    notes: "住宅ローン返済継続"
  },
  {
    year: current_year + 6,
    annual_income: 6_200_000,
    annual_expense: 7_300_000,
    notes: "車購入年、一時的に支出増"
  },
  {
    year: current_year + 7,
    annual_income: 6_400_000,
    annual_expense: 7_100_000,
    notes: ""
  },
  {
    year: current_year + 8,
    annual_income: 6_600_000,
    annual_expense: 7_200_000,
    notes: ""
  },
  {
    year: current_year + 9,
    annual_income: 6_800_000,
    annual_expense: 7_300_000,
    notes: "長男小学校入学"
  }
]

budgets_data.each do |data|
  budget = AnnualBudget.create!(data)
  net = budget.net_income >= 0 ? "+#{budget.net_income.to_i}" : budget.net_income.to_i
  puts "✓ #{budget.year}年 収入: #{budget.annual_income.to_i.to_s.reverse.scan(/\d{1,3}/).join(',').reverse}円 | 支出: #{budget.annual_expense.to_i.to_s.reverse.scan(/\d{1,3}/).join(',').reverse}円 | 純収入: #{net}円"
end

puts "\n作成完了: #{AnnualBudget.count}件の年次予算\n"

puts "\n========================================="
puts "シードデータの作成が完了しました！"
puts "=========================================\n"
puts "ライフイベント: #{LifeEvent.count}件"
puts "年次予算: #{AnnualBudget.count}件"
puts "\n動作確認用コマンド:"
puts "  docker-compose exec backend bundle exec rails console"
puts "  > LifeEvent.upcoming.count"
puts "  > AnnualBudget.surplus.count"
puts "=========================================\n"
