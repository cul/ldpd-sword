# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20201026223435) do

  create_table "collections", force: :cascade do |t|
    t.string   "name",                                        null: false
    t.string   "atom_title",                                  null: false
    t.string   "slug",                                        null: false
    t.string   "hyacinth_project_string_key"
    t.string   "parser"
    t.text     "abstract"
    t.text     "mime_types"
    t.text     "sword_package_types"
    t.boolean  "mediation_enabled",           default: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "collections", ["name"], name: "index_collections_on_name", unique: true
  add_index "collections", ["slug"], name: "index_collections_on_slug", unique: true

  create_table "depositor_collection_pairings", force: :cascade do |t|
    t.integer  "depositor_id"
    t.integer  "collection_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "depositor_collection_pairings", ["collection_id"], name: "index_depositor_collection_pairings_on_collection_id"
  add_index "depositor_collection_pairings", ["depositor_id"], name: "index_depositor_collection_pairings_on_depositor_id"

  create_table "depositors", force: :cascade do |t|
    t.string   "name",                         null: false
    t.string   "basic_authentication_user_id", null: false
    t.string   "password_digest",              null: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "depositors", ["basic_authentication_user_id"], name: "index_depositors_on_basic_authentication_user_id", unique: true
  add_index "depositors", ["name"], name: "index_depositors_on_name", unique: true

  create_table "deposits", force: :cascade do |t|
    t.integer  "depositor_id"
    t.integer  "collection_id"
    t.string   "title"
    t.string   "item_in_hyacinth"
    t.integer  "status",            default: 0, null: false
    t.text     "deposit_files"
    t.text     "deposit_errors"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "depositor_user_id"
    t.string   "collection_slug"
  end

  add_index "deposits", ["collection_id"], name: "index_deposits_on_collection_id"
  add_index "deposits", ["collection_slug"], name: "index_deposits_on_collection_slug"
  add_index "deposits", ["depositor_id"], name: "index_deposits_on_depositor_id"
  add_index "deposits", ["depositor_user_id"], name: "index_deposits_on_depositor_user_id"
  add_index "deposits", ["status"], name: "index_deposits_on_status"

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "name",                   default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "admin",                  default: false, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
