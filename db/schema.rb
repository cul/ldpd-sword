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

ActiveRecord::Schema.define(version: 20161011172922) do

  create_table "collections", force: :cascade do |t|
    t.string   "name",                        limit: 255,                   null: false
    t.string   "atom_title",                  limit: 255,                   null: false
    t.string   "slug",                        limit: 255,                   null: false
    t.string   "hyacinth_project_string_key", limit: 255
    t.string   "parser",                      limit: 255
    t.text     "abstract",                    limit: 65535
    t.text     "mime_types",                  limit: 65535
    t.text     "sword_package_types",         limit: 65535
    t.boolean  "mediation_enabled",                         default: false
    t.datetime "created_at",                                                null: false
    t.datetime "updated_at",                                                null: false
  end

  add_index "collections", ["name"], name: "index_collections_on_name", unique: true, using: :btree
  add_index "collections", ["slug"], name: "index_collections_on_slug", unique: true, using: :btree

  create_table "depositor_collection_pairings", force: :cascade do |t|
    t.integer  "depositor_id",  limit: 4
    t.integer  "collection_id", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "depositor_collection_pairings", ["collection_id"], name: "index_depositor_collection_pairings_on_collection_id", using: :btree
  add_index "depositor_collection_pairings", ["depositor_id"], name: "index_depositor_collection_pairings_on_depositor_id", using: :btree

  create_table "depositors", force: :cascade do |t|
    t.string   "name",                         limit: 255, null: false
    t.string   "basic_authentication_user_id", limit: 255, null: false
    t.string   "password_digest",              limit: 255, null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "depositors", ["basic_authentication_user_id"], name: "index_depositors_on_basic_authentication_user_id", unique: true, using: :btree
  add_index "depositors", ["name"], name: "index_depositors_on_name", unique: true, using: :btree

  create_table "deposits", force: :cascade do |t|
    t.integer  "depositor_id",         limit: 4
    t.integer  "collection_id",        limit: 4
    t.string   "title",                limit: 255
    t.text     "abstract",             limit: 65535
    t.string   "item_in_hyacinth",     limit: 255
    t.datetime "embargo_release_date"
    t.integer  "status",               limit: 4,     default: 0, null: false
    t.text     "deposit_errors",       limit: 65535
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
  end

  add_index "deposits", ["collection_id"], name: "index_deposits_on_collection_id", using: :btree
  add_index "deposits", ["depositor_id"], name: "index_deposits_on_depositor_id", using: :btree
  add_index "deposits", ["status"], name: "index_deposits_on_status", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "name",                   limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.boolean  "admin",                              default: false, null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "depositor_collection_pairings", "collections"
  add_foreign_key "depositor_collection_pairings", "depositors"
  add_foreign_key "deposits", "collections"
  add_foreign_key "deposits", "depositors"
end
