# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_26_223435) do

  create_table "collections", force: :cascade do |t|
    t.string "name", null: false
    t.string "atom_title", null: false
    t.string "slug", null: false
    t.string "hyacinth_project_string_key"
    t.string "parser"
    t.text "abstract"
    t.text "mime_types"
    t.text "sword_package_types"
    t.boolean "mediation_enabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_collections_on_name", unique: true
    t.index ["slug"], name: "index_collections_on_slug", unique: true
  end

  create_table "depositor_collection_pairings", force: :cascade do |t|
    t.integer "depositor_id"
    t.integer "collection_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_depositor_collection_pairings_on_collection_id"
    t.index ["depositor_id"], name: "index_depositor_collection_pairings_on_depositor_id"
  end

  create_table "depositors", force: :cascade do |t|
    t.string "name", null: false
    t.string "basic_authentication_user_id", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["basic_authentication_user_id"], name: "index_depositors_on_basic_authentication_user_id", unique: true
    t.index ["name"], name: "index_depositors_on_name", unique: true
  end

  create_table "deposits", force: :cascade do |t|
    t.integer "depositor_id"
    t.integer "collection_id"
    t.string "title"
    t.string "item_in_hyacinth"
    t.integer "status", default: 0, null: false
    t.text "deposit_files"
    t.text "deposit_errors"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "depositor_user_id"
    t.string "collection_slug"
    t.index ["collection_id"], name: "index_deposits_on_collection_id"
    t.index ["collection_slug"], name: "index_deposits_on_collection_slug"
    t.index ["depositor_id"], name: "index_deposits_on_depositor_id"
    t.index ["depositor_user_id"], name: "index_deposits_on_depositor_user_id"
    t.index ["status"], name: "index_deposits_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "name", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
