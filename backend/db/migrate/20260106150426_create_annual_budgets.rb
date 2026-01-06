class CreateAnnualBudgets < ActiveRecord::Migration[7.1]
  def change
    create_table :annual_budgets do |t|
      t.integer :year
      t.decimal :annual_income
      t.decimal :annual_expense
      t.text :notes

      t.timestamps
    end
  end
end
