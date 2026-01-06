class AnnualBudgetBlueprint < Blueprinter::Base
  identifier :id

  fields :year, :annual_income, :annual_expense, :notes
  
  field :net_income do |budget|
    income = budget.annual_income || 0
    expense = budget.annual_expense || 0
    income - expense
  end
  
  field :created_at do |budget|
    budget.created_at.iso8601
  end
  
  field :updated_at do |budget|
    budget.updated_at.iso8601
  end
end
