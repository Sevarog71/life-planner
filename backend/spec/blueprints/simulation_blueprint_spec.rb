require 'rails_helper'

RSpec.describe SimulationBlueprint do
  describe '.render (JSONシリアライズ)' do
    it 'シミュレーション結果を正しくJSON形式にシリアライズできること' do
      event = create(:life_event,
        name: '車購入',
        event_type: 'car_purchase',
        scheduled_date: Date.new(2025, 6, 15),
        estimated_cost: 500000
      )

      result = {
        start_year: 2025,
        end_year: 2025,
        initial_assets: 1000000,
        final_assets: 2500000,
        years: [
          {
            year: 2025,
            annual_income: 5000000,
            annual_expense: 3000000,
            net_income: 2000000,
            event_costs: 500000,
            events: [event],
            year_end_assets: 2500000
          }
        ]
      }

      json = SimulationBlueprint.render(result)
      parsed = JSON.parse(json)

      # 全体の期間情報
      expect(parsed['start_year']).to eq(2025)
      expect(parsed['end_year']).to eq(2025)
      expect(parsed['initial_assets']).to eq(1000000)
      expect(parsed['final_assets']).to eq(2500000)

      # 年次データの配列
      expect(parsed['years']).to be_an(Array)
      expect(parsed['years'].length).to eq(1)

      # 年次データの詳細
      year_data = parsed['years'].first
      expect(year_data['year']).to eq(2025)
      expect(year_data['annual_income']).to eq(5000000)
      expect(year_data['annual_expense']).to eq(3000000)
      expect(year_data['net_income']).to eq(2000000)
      expect(year_data['event_costs']).to eq(500000)
      expect(year_data['year_end_assets']).to eq(2500000)

      # イベントデータの配列
      expect(year_data['events']).to be_an(Array)
      expect(year_data['events'].length).to eq(1)

      # イベントの詳細情報（id, name, event_type, scheduled_date, estimated_cost）
      event_data = year_data['events'].first
      expect(event_data['id']).to eq(event.id)
      expect(event_data['name']).to eq('車購入')
      expect(event_data['event_type']).to eq('car_purchase')
      expect(event_data['scheduled_date']).to eq('2025-06-15')
      expect(event_data['estimated_cost']).to eq(500000)
    end

    it '複数年度のシミュレーション結果を正しくシリアライズできること' do
      event1 = create(:life_event, scheduled_date: Date.new(2025, 6, 15), estimated_cost: 500000)
      event2 = create(:life_event, scheduled_date: Date.new(2026, 12, 1), estimated_cost: 300000)

      result = {
        start_year: 2025,
        end_year: 2026,
        initial_assets: 0,
        final_assets: 3500000,
        years: [
          {
            year: 2025,
            annual_income: 5000000,
            annual_expense: 3000000,
            net_income: 2000000,
            event_costs: 500000,
            events: [event1],
            year_end_assets: 1500000
          },
          {
            year: 2026,
            annual_income: 5500000,
            annual_expense: 3200000,
            net_income: 2300000,
            event_costs: 300000,
            events: [event2],
            year_end_assets: 3500000
          }
        ]
      }

      json = SimulationBlueprint.render(result)
      parsed = JSON.parse(json)

      expect(parsed['years'].length).to eq(2)
      expect(parsed['years'][0]['year']).to eq(2025)
      expect(parsed['years'][1]['year']).to eq(2026)
    end

    it 'イベントが存在しない年度を正しくシリアライズできること' do
      result = {
        start_year: 2025,
        end_year: 2025,
        initial_assets: 0,
        final_assets: 2000000,
        years: [
          {
            year: 2025,
            annual_income: 5000000,
            annual_expense: 3000000,
            net_income: 2000000,
            event_costs: 0,
            events: [],
            year_end_assets: 2000000
          }
        ]
      }

      json = SimulationBlueprint.render(result)
      parsed = JSON.parse(json)

      year_data = parsed['years'].first
      expect(year_data['events']).to eq([])
      expect(year_data['event_costs']).to eq(0)
    end
  end
end
