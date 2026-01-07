class SimulationBlueprint < Blueprinter::Base
  fields :start_year, :end_year, :initial_assets, :final_assets

  field :years do |result|
    result[:years].map do |year_data|
      {
        year: year_data[:year],
        annual_income: year_data[:annual_income],
        annual_expense: year_data[:annual_expense],
        net_income: year_data[:net_income],
        event_costs: year_data[:event_costs],
        events: year_data[:events].map do |event|
          {
            id: event.id,
            name: event.name,
            event_type: event.event_type,
            scheduled_date: event.scheduled_date.iso8601,
            estimated_cost: event.estimated_cost
          }
        end,
        year_end_assets: year_data[:year_end_assets]
      }
    end
  end
end
