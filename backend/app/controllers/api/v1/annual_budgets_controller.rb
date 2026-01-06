module Api
  module V1
    class AnnualBudgetsController < ApplicationController
      before_action :set_annual_budget, only: [:show, :update, :destroy]

      # GET /api/v1/annual_budgets
      def index
        @annual_budgets = AnnualBudget.ordered
        render json: AnnualBudgetBlueprint.render(@annual_budgets)
      end

      # GET /api/v1/annual_budgets/:id
      def show
        render json: AnnualBudgetBlueprint.render(@annual_budget)
      end

      # POST /api/v1/annual_budgets
      def create
        @annual_budget = AnnualBudget.new(annual_budget_params)

        if @annual_budget.save
          render json: AnnualBudgetBlueprint.render(@annual_budget), status: :created
        else
          render json: { errors: @annual_budget.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/annual_budgets/:id
      def update
        if @annual_budget.update(annual_budget_params)
          render json: AnnualBudgetBlueprint.render(@annual_budget)
        else
          render json: { errors: @annual_budget.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/annual_budgets/:id
      def destroy
        @annual_budget.destroy
        head :no_content
      end

      private

      def set_annual_budget
        @annual_budget = AnnualBudget.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Annual budget not found" }, status: :not_found
      end

      def annual_budget_params
        params.require(:annual_budget).permit(:year, :annual_income, :annual_expense, :notes)
      end
    end
  end
end
