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

ActiveRecord::Schema[7.1].define(version: 2025_09_29_130030) do
  create_table "customers", force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "instruments", force: :cascade do |t|
    t.string "isin", null: false
    t.string "kind", null: false
    t.string "name", null: false
    t.decimal "price", precision: 15, scale: 2, null: false
    t.integer "sri", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["isin"], name: "index_instruments_on_isin", unique: true
    t.index ["kind"], name: "index_instruments_on_kind"
  end

  create_table "investments", force: :cascade do |t|
    t.integer "portfolio_id", null: false
    t.integer "instrument_id", null: false
    t.decimal "amount", precision: 15, scale: 2, null: false
    t.decimal "weight", precision: 8, scale: 4, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["instrument_id"], name: "index_investments_on_instrument_id"
    t.index ["portfolio_id", "instrument_id"], name: "index_investments_on_portfolio_id_and_instrument_id", unique: true
    t.index ["portfolio_id"], name: "index_investments_on_portfolio_id"
  end

  create_table "portfolios", force: :cascade do |t|
    t.integer "customer_id", null: false
    t.string "name", null: false
    t.string "kind", null: false
    t.decimal "total_amount", precision: 15, scale: 2, default: "0.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_portfolios_on_customer_id"
    t.index ["kind"], name: "index_portfolios_on_kind"
  end

  add_foreign_key "investments", "instruments"
  add_foreign_key "investments", "portfolios"
  add_foreign_key "portfolios", "customers"
end
