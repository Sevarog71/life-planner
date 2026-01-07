# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_01_07_001445) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "annual_budgets", force: :cascade do |t|
    t.integer "year"
    t.decimal "annual_income", precision: 15, scale: 2
    t.decimal "annual_expense", precision: 15, scale: 2
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["year"], name: "index_annual_budgets_on_year", unique: true, comment: "年度の一意性を保証"
  end

  create_table "life_events", force: :cascade do |t|
    t.string "event_type"
    t.string "name"
    t.date "scheduled_date"
    t.decimal "estimated_cost", precision: 12, scale: 2
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["event_type"], name: "index_life_events_on_event_type", comment: "フィルタリング用"
    t.index ["scheduled_date"], name: "index_life_events_on_scheduled_date", comment: "ソートと検索用"
  end

end
