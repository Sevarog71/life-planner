require 'rails_helper'

RSpec.describe 'Api::V1::Simulation (シミュレーションAPI)', type: :request do
  describe 'GET /api/v1/simulation' do
    context '正常なパラメータでリクエストした場合' do
      let!(:budget_2025) { create(:annual_budget, year: 2025, annual_income: 5000000, annual_expense: 3000000) }
      let!(:event_2025) { create(:life_event, scheduled_date: Date.new(2025, 6, 15), estimated_cost: 500000, name: '車購入') }

      it '全パラメータ(start_year, end_year, initial_assets)を指定した場合、正しいシミュレーション結果が返されること' do
        get '/api/v1/simulation', params: { start_year: 2025, end_year: 2025, initial_assets: 1000000 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['start_year']).to eq(2025)
        expect(json['end_year']).to eq(2025)
        expect(json['initial_assets']).to eq(1000000.0)
        expect(json['years']).to be_an(Array)
        expect(json['years'].length).to eq(1)
        expect(json['final_assets']).to eq(2500000.0)
      end

      it '初期資産(initial_assets)を指定しない場合、デフォルト値0でシミュレーションされること' do
        get '/api/v1/simulation', params: { start_year: 2025, end_year: 2025 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['initial_assets']).to eq(0)
      end

      it '年次ごとの内訳データ(annual_income, annual_expense, net_income等)が含まれること' do
        get '/api/v1/simulation', params: { start_year: 2025, end_year: 2025, initial_assets: 0 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        year_data = json['years'].first
        expect(year_data['year']).to eq(2025)
        expect(year_data['annual_income']).to eq(5000000)
        expect(year_data['annual_expense']).to eq(3000000)
        expect(year_data['net_income']).to eq(2000000)
        expect(year_data['event_costs']).to eq(500000)
        expect(year_data['year_end_assets']).to eq(1500000)
      end

      it 'イベント詳細(events)がレスポンスに含まれること' do
        get '/api/v1/simulation', params: { start_year: 2025, end_year: 2025, initial_assets: 0 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        events = json['years'].first['events']
        expect(events).to be_an(Array)
        expect(events.length).to eq(1)
        expect(events.first['name']).to eq('車購入')
        expect(events.first['estimated_cost']).to eq(500000)
      end

      it '複数年度にわたるシミュレーションが正しく実行されること' do
        budget_2026 = create(:annual_budget, year: 2026, annual_income: 5500000, annual_expense: 3200000)

        get '/api/v1/simulation', params: { start_year: 2025, end_year: 2026, initial_assets: 0 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json['years'].length).to eq(2)
        expect(json['years'][0]['year']).to eq(2025)
        expect(json['years'][1]['year']).to eq(2026)
      end
    end

    context '異常なパラメータでリクエストした場合' do
      it '開始年(start_year)が未指定の場合、422エラーとエラーメッセージが返されること' do
        get '/api/v1/simulation', params: { end_year: 2025 }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)

        expect(json['errors']).to be_present
        expect(json['errors']).to include("start_year must be present")
      end

      it '終了年(end_year)が未指定の場合、422エラーとエラーメッセージが返されること' do
        get '/api/v1/simulation', params: { start_year: 2025 }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)

        expect(json['errors']).to be_present
        expect(json['errors']).to include("end_year must be present")
      end

      it '終了年(end_year)が開始年(start_year)より小さい場合、422エラーが返されること' do
        get '/api/v1/simulation', params: { start_year: 2026, end_year: 2025 }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)

        expect(json['errors']).to include("end_year must be greater than or equal to start_year")
      end

      it '年範囲が100年を超える場合、DoS防止のため422エラーが返されること' do
        get '/api/v1/simulation', params: { start_year: 2000, end_year: 2200 }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)

        expect(json['errors']).to include("year range is too large (max 100 years)")
      end

      it '開始年(start_year)が許容範囲外の場合、422エラーが返されること' do
        get '/api/v1/simulation', params: { start_year: 1800, end_year: 2025 }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)

        expect(json['errors']).to include("start_year must be between 1900 and 2200")
      end

      it '終了年(end_year)が許容範囲外の場合、422エラーが返されること' do
        get '/api/v1/simulation', params: { start_year: 2025, end_year: 2300 }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)

        expect(json['errors']).to include("end_year must be between 1900 and 2200")
      end
    end

    context '年次予算データ(AnnualBudget)が存在しない場合' do
      it '予算が存在しない年度は収入・支出が0としてシミュレーションされること' do
        get '/api/v1/simulation', params: { start_year: 2025, end_year: 2025, initial_assets: 1000000 }

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        year_data = json['years'].first
        expect(year_data['annual_income']).to eq(0)
        expect(year_data['annual_expense']).to eq(0)
        expect(year_data['year_end_assets']).to eq(1000000)
      end
    end

    context 'レスポンス形式の検証' do
      let!(:budget_2025) { create(:annual_budget, year: 2025, annual_income: 5000000, annual_expense: 3000000) }

      it '正しいJSON構造(start_year, end_year, initial_assets, final_assets, years)が返されること' do
        get '/api/v1/simulation', params: { start_year: 2025, end_year: 2025, initial_assets: 0 }

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(/application\/json/)

        json = JSON.parse(response.body)
        expect(json).to have_key('start_year')
        expect(json).to have_key('end_year')
        expect(json).to have_key('initial_assets')
        expect(json).to have_key('final_assets')
        expect(json).to have_key('years')
      end
    end
  end
end
