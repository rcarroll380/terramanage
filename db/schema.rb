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

ActiveRecord::Schema[8.1].define(version: 2026_09_17_010000) do
  create_table "accounts", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "account_type", null: false
    t.boolean "active", default: true, null: false
    t.decimal "balance", precision: 12, scale: 2, default: "0.0", null: false
    t.string "book_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.string "number", null: false
    t.string "parent_id", limit: 36
    t.datetime "updated_at", null: false
    t.index ["book_id", "number"], name: "index_accounts_on_book_id_and_number", unique: true
    t.index ["book_id"], name: "index_accounts_on_book_id"
    t.index ["parent_id"], name: "index_accounts_on_parent_id"
  end

  create_table "books", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "entities", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.string "address_line1"
    t.string "address_line2"
    t.string "city"
    t.datetime "created_at", null: false
    t.string "entity_type", null: false
    t.string "name", null: false
    t.string "postal_code", limit: 10
    t.string "state", limit: 2
    t.datetime "updated_at", null: false
  end

  create_table "transactions", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "account_id", limit: 36, null: false
    t.decimal "balance", precision: 12, scale: 2, default: "0.0", null: false
    t.string "book_id", limit: 36, null: false
    t.string "category_account_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.date "date", null: false
    t.decimal "deposit", precision: 12, scale: 2, default: "0.0", null: false
    t.string "entity_id", limit: 36, null: false
    t.text "memo"
    t.string "number"
    t.decimal "payment", precision: 12, scale: 2, default: "0.0", null: false
    t.boolean "reconciled", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["book_id", "date", "id"], name: "index_transactions_on_book_id_and_date_and_id"
    t.index ["book_id"], name: "index_transactions_on_book_id"
    t.index ["category_account_id"], name: "index_transactions_on_category_account_id"
    t.index ["entity_id"], name: "index_transactions_on_entity_id"
  end

  add_foreign_key "accounts", "accounts", column: "parent_id"
  add_foreign_key "accounts", "books"
  add_foreign_key "transactions", "accounts"
  add_foreign_key "transactions", "accounts", column: "category_account_id"
  add_foreign_key "transactions", "books"
  add_foreign_key "transactions", "entities"
end
