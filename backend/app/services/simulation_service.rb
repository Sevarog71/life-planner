# Service class for calculating life plan financial simulation
#
# Calculates year-by-year assets based on:
# - Annual budgets (income and expenses)
# - Life event costs
# - Initial asset amount
#
# Formula: asset[year] = asset[year-1] + income - expense - events
#
# @example
#   service = SimulationService.new(
#     start_year: 2025,
#     end_year: 2030,
#     initial_assets: 1000000
#   )
#   result = service.execute if service.valid?
class SimulationService
  attr_reader :start_year, :end_year, :initial_assets, :errors

  def initialize(start_year:, end_year:, initial_assets: 0)
    @start_year = start_year.to_i
    @end_year = end_year.to_i
    @initial_assets = initial_assets.to_f
    @errors = []
  end

  def execute
    return nil unless valid?

    {
      start_year: start_year,
      end_year: end_year,
      initial_assets: initial_assets,
      years: calculate_years,
      final_assets: @final_assets
    }
  end

  def valid?
    validate_year_range
    validate_initial_assets
    errors.empty?
  end

  private

  def validate_year_range
    errors << "start_year must be present" if start_year.nil? || start_year.zero?
    errors << "end_year must be present" if end_year.nil? || end_year.zero?
    errors << "end_year must be greater than or equal to start_year" if end_year < start_year
    errors << "year range is too large (max 100 years)" if (end_year - start_year) > 100
    errors << "start_year must be between 1900 and 2200" unless start_year.between?(1900, 2200)
    errors << "end_year must be between 1900 and 2200" unless end_year.between?(1900, 2200)
  end

  def validate_initial_assets
    errors << "initial_assets must be a number" unless initial_assets.is_a?(Numeric)
  end

  def calculate_years
    cumulative_assets = initial_assets
    years_data = []

    (start_year..end_year).each do |year|
      budget = AnnualBudget.find_by(year: year)
      events = LifeEvent.in_year(year).with_cost.ordered

      annual_income = budget&.annual_income || 0
      annual_expense = budget&.annual_expense || 0
      net_income = annual_income - annual_expense
      event_costs = events.sum(:estimated_cost) || 0

      cumulative_assets = cumulative_assets + net_income - event_costs

      years_data << {
        year: year,
        annual_income: annual_income,
        annual_expense: annual_expense,
        net_income: net_income,
        event_costs: event_costs,
        events: events,
        year_end_assets: cumulative_assets
      }
    end

    @final_assets = cumulative_assets
    years_data
  end
end
