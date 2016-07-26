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

ActiveRecord::Schema.define(version: 20160707205347) do

  create_table "collections", force: :cascade do |t|
    t.string   "name",               limit: 255,   null: false
    t.text     "allowed_mime_types", limit: 65535
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "collections", ["name"], name: "index_collections_on_name", unique: true, using: :btree

  create_table "depositors", force: :cascade do |t|
    t.string   "name",               limit: 255,   null: false
    t.text     "allowed_mime_types", limit: 65535
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "depositors", ["name"], name: "index_depositors_on_name", unique: true, using: :btree

  create_table "packages", force: :cascade do |t|
    t.integer  "sword_deposit_id", limit: 4
    t.string   "filename",         limit: 255,   null: false
    t.text     "contents",         limit: 65535
    t.string   "filepath",         limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "packages", ["sword_deposit_id"], name: "index_packages_on_sword_deposit_id", using: :btree

  create_table "sword_deposits", force: :cascade do |t|
    t.integer  "depositor_id",                        limit: 4
    t.integer  "collection_id",                       limit: 4
    t.string   "title",                               limit: 255
    t.string   "item_in_hyacinth",                    limit: 255
    t.datetime "embargo_release_date"
    t.integer  "status",                              limit: 4,     default: 0,     null: false
    t.text     "deposit_errors",                      limit: 65535
    t.string   "header_content_type",                 limit: 255
    t.string   "header_content_md5",                  limit: 255
    t.string   "header_user_agent",                   limit: 255
    t.string   "header_content_disposition_filename", limit: 255
    t.string   "header_x_on_behalf_of",               limit: 255
    t.boolean  "header_x_verbose",                                  default: false
    t.boolean  "header_x_no_op",                                    default: false
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
  end

  add_index "sword_deposits", ["collection_id"], name: "index_sword_deposits_on_collection_id", using: :btree
  add_index "sword_deposits", ["depositor_id"], name: "index_sword_deposits_on_depositor_id", using: :btree
  add_index "sword_deposits", ["status"], name: "index_sword_deposits_on_status", using: :btree

  add_foreign_key "packages", "sword_deposits"
  add_foreign_key "sword_deposits", "collections"
  add_foreign_key "sword_deposits", "depositors"
end
