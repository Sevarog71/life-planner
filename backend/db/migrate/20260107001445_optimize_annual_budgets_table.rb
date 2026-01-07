class OptimizeAnnualBudgetsTable < ActiveRecord::Migration[7.1]
  def change
    # yearにユニーク制約（DB レベル）
    add_index :annual_budgets, :year, unique: true, comment: '年度の一意性を保証'

    # annual_income, annual_expenseのprecisionとscale指定
    change_column :annual_budgets, :annual_income, :decimal, precision: 15, scale: 2
    change_column :annual_budgets, :annual_expense, :decimal, precision: 15, scale: 2
  end
end
