module Api
  module V1
    class SimulationController < ApplicationController
      # GET /api/v1/simulation
      def show
        service = SimulationService.new(
          start_year: params[:start_year],
          end_year: params[:end_year],
          initial_assets: params[:initial_assets] || 0
        )

        unless service.valid?
          return render json: { errors: service.errors }, status: :unprocessable_entity
        end

        result = service.execute
        render json: SimulationBlueprint.render(result)
      end
    end
  end
end
