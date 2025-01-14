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

ActiveRecord::Schema[7.2].define(version: 2025_01_15_171018) do
  create_table "deposits", force: :cascade do |t|
    t.integer "depositor_id"
    t.integer "collection_id"
    t.string "title"
    t.string "item_in_hyacinth"
    t.integer "status", default: 0, null: false
    t.text "deposit_files"
    t.text "deposit_errors"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "depositor_user_id"
    t.string "collection_slug"
    t.text "asset_pids"
    t.boolean "ingest_confirmed"
    t.string "content_path"
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
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "uid"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end
end
