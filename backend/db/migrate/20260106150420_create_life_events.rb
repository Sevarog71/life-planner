class CreateLifeEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :life_events do |t|
      t.string :event_type
      t.string :name
      t.date :scheduled_date
      t.decimal :estimated_cost
      t.text :notes

      t.timestamps
    end
  end
end
