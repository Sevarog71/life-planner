module Api
  module V1
    class LifeEventsController < ApplicationController
      before_action :set_life_event, only: [:show, :update, :destroy]

      # GET /api/v1/life_events
      def index
        @life_events = LifeEvent.order(scheduled_date: :asc)
        render json: LifeEventBlueprint.render(@life_events)
      end

      # GET /api/v1/life_events/:id
      def show
        render json: LifeEventBlueprint.render(@life_event)
      end

      # POST /api/v1/life_events
      def create
        @life_event = LifeEvent.new(life_event_params)

        if @life_event.save
          render json: LifeEventBlueprint.render(@life_event), status: :created
        else
          render json: { errors: @life_event.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/life_events/:id
      def update
        if @life_event.update(life_event_params)
          render json: LifeEventBlueprint.render(@life_event)
        else
          render json: { errors: @life_event.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/life_events/:id
      def destroy
        @life_event.destroy
        head :no_content
      end

      private

      def set_life_event
        @life_event = LifeEvent.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Life event not found" }, status: :not_found
      end

      def life_event_params
        params.require(:life_event).permit(:event_type, :name, :scheduled_date, :estimated_cost, :notes)
      end
    end
  end
end
