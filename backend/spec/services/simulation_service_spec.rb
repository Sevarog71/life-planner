require 'rails_helper'

RSpec.describe SimulationService do
  describe '#execute (シミュレーション実行)' do
    context '正常なパラメータが指定された場合' do
      let!(:budget_2025) { create(:annual_budget, year: 2025, annual_income: 5000000, annual_expense: 3000000) }
      let!(:budget_2026) { create(:annual_budget, year: 2026, annual_income: 5500000, annual_expense: 3200000) }
      let!(:event_2025) { create(:life_event, scheduled_date: Date.new(2025, 6, 15), estimated_cost: 500000, name: '車購入') }
      let!(:event_2026) { create(:life_event, scheduled_date: Date.new(2026, 12, 1), estimated_cost: 300000, name: '旅行') }

      it '初期資産(initial_assets)を含めた累積資産計算が正しく行われること' do
        service = SimulationService.new(start_year: 2025, end_year: 2026, initial_assets: 1000000)
        result = service.execute

        expect(result[:start_year]).to eq(2025)
        expect(result[:end_year]).to eq(2026)
        expect(result[:initial_assets]).to eq(1000000)

        # 2025年: 1,000,000 + (5,000,000 - 3,000,000) - 500,000 = 2,500,000
        expect(result[:years][0][:year_end_assets]).to eq(2500000)

        # 2026年: 2,500,000 + (5,500,000 - 3,200,000) - 300,000 = 4,500,000
        expect(result[:years][1][:year_end_assets]).to eq(4500000)
        expect(result[:final_assets]).to eq(4500000)
      end

      it '各年のイベント詳細(events)が結果に含まれること' do
        service = SimulationService.new(start_year: 2025, end_year: 2026, initial_assets: 0)
        result = service.execute

        expect(result[:years][0][:events].length).to eq(1)
        expect(result[:years][0][:events].first.name).to eq('車購入')
      end

      it '純利益(net_income)の計算が正しく行われること' do
        service = SimulationService.new(start_year: 2025, end_year: 2025, initial_assets: 0)
        result = service.execute

        expect(result[:years][0][:annual_income]).to eq(5000000)
        expect(result[:years][0][:annual_expense]).to eq(3000000)
        expect(result[:years][0][:net_income]).to eq(2000000)
      end
    end

    context '年次予算データ(AnnualBudget)が存在しない年がある場合' do
      it '収入(annual_income)と支出(annual_expense)に0が使用されること' do
        service = SimulationService.new(start_year: 2025, end_year: 2026, initial_assets: 1000000)
        result = service.execute

        expect(result[:years][0][:annual_income]).to eq(0)
        expect(result[:years][0][:annual_expense]).to eq(0)
        expect(result[:years][0][:year_end_assets]).to eq(1000000)
      end
    end

    context 'イベント費用(estimated_cost)がnilのライフイベントが存在する場合' do
      let!(:event_no_cost) { create(:life_event, scheduled_date: Date.new(2025, 6, 15), estimated_cost: nil, name: 'イベント') }

      it '費用なしイベントが計算から除外されること' do
        service = SimulationService.new(start_year: 2025, end_year: 2025, initial_assets: 1000000)
        result = service.execute

        expect(result[:years][0][:event_costs]).to eq(0)
        expect(result[:years][0][:events]).to be_empty
      end
    end

    context '初期資産(initial_assets)が未指定の場合' do
      let!(:budget_2025) { create(:annual_budget, year: 2025, annual_income: 1000000, annual_expense: 500000) }

      it 'デフォルト値の0が使用されること' do
        service = SimulationService.new(start_year: 2025, end_year: 2025)
        result = service.execute

        expect(result[:initial_assets]).to eq(0)
        expect(result[:years][0][:year_end_assets]).to eq(500000)
      end
    end

    context 'マイナス資産（負債シナリオ）の場合' do
      let!(:budget_2025) { create(:annual_budget, year: 2025, annual_income: 1000000, annual_expense: 2000000) }

      it '年末資産(year_end_assets)がマイナス値を許容すること' do
        service = SimulationService.new(start_year: 2025, end_year: 2025, initial_assets: 0)
        result = service.execute

        expect(result[:years][0][:year_end_assets]).to eq(-1000000)
        expect(result[:final_assets]).to eq(-1000000)
      end
    end
  end

  describe '#valid? (バリデーション)' do
    context '正常なパラメータの場合' do
      it '有効な年範囲に対してtrueを返すこと' do
        service = SimulationService.new(start_year: 2025, end_year: 2030, initial_assets: 0)
        expect(service.valid?).to be true
        expect(service.errors).to be_empty
      end
    end

    context '異常なパラメータの場合' do
      it '開始年(start_year)がnilの場合、エラーメッセージが含まれること' do
        service = SimulationService.new(start_year: nil, end_year: 2025)
        expect(service.valid?).to be false
        expect(service.errors).to include("start_year must be present")
      end

      it '開始年(start_year)が0の場合、エラーメッセージが含まれること' do
        service = SimulationService.new(start_year: 0, end_year: 2025)
        expect(service.valid?).to be false
        expect(service.errors).to include("start_year must be present")
      end

      it '終了年(end_year)がnilの場合、エラーメッセージが含まれること' do
        service = SimulationService.new(start_year: 2025, end_year: nil)
        expect(service.valid?).to be false
        expect(service.errors).to include("end_year must be present")
      end

      it '終了年(end_year)が開始年(start_year)より小さい場合、エラーメッセージが含まれること' do
        service = SimulationService.new(start_year: 2026, end_year: 2025)
        expect(service.valid?).to be false
        expect(service.errors).to include("end_year must be greater than or equal to start_year")
      end

      it '年範囲が100年を超える場合、DoS防止のためエラーメッセージが含まれること' do
        service = SimulationService.new(start_year: 2000, end_year: 2200)
        expect(service.valid?).to be false
        expect(service.errors).to include("year range is too large (max 100 years)")
      end

      it '開始年(start_year)が下限(1900)未満の場合、エラーメッセージが含まれること' do
        service = SimulationService.new(start_year: 1800, end_year: 2025)
        expect(service.valid?).to be false
        expect(service.errors).to include("start_year must be between 1900 and 2200")
      end

      it '開始年(start_year)が上限(2200)を超える場合、エラーメッセージが含まれること' do
        service = SimulationService.new(start_year: 2300, end_year: 2350)
        expect(service.valid?).to be false
        expect(service.errors).to include("start_year must be between 1900 and 2200")
      end

      it '終了年(end_year)が下限(1900)未満の場合、エラーメッセージが含まれること' do
        service = SimulationService.new(start_year: 1900, end_year: 1800)
        expect(service.valid?).to be false
        expect(service.errors).to include("end_year must be between 1900 and 2200")
      end

      it '終了年(end_year)が上限(2200)を超える場合、エラーメッセージが含まれること' do
        service = SimulationService.new(start_year: 2100, end_year: 2300)
        expect(service.valid?).to be false
        expect(service.errors).to include("end_year must be between 1900 and 2200")
      end
    end
  end
end
