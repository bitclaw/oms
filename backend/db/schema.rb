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

ActiveRecord::Schema[7.2].define(version: 2026_03_23_202433) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "orders", comment: "Stores customer orders placed through the OMS", force: :cascade do |t|
    t.string "customer_name", null: false, comment: "Full name of the customer placing the order"
    t.string "product", null: false, comment: "Name or description of the product ordered"
    t.integer "amount_cents", null: false, comment: "Order total in cents to avoid floating-point precision issues"
    t.string "status", default: "pending", null: false, comment: "Lifecycle status of the order: pending, completed, cancelled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["status"], name: "index_orders_on_status", comment: "Supports filtering orders by status"
  end
end
