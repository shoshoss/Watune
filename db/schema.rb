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

ActiveRecord::Schema[7.1].define(version: 2024_05_04_005657) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "authentications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider", null: false
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["provider", "uid"], name: "index_authentications_on_provider_and_uid", unique: true
    t.index ["user_id"], name: "index_authentications_on_user_id"
  end

  create_table "posts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "body", null: false
    t.binary "audio"
    t.integer "privacy", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "duration"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", limit: 255, null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "display_name", limit: 50
    t.string "username_slug", limit: 15
    t.string "self_introduction", limit: 500
    t.string "avatar", limit: 255
    t.integer "role", default: 0
    t.string "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.integer "access_count_to_reset_password_page", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username_slug"], name: "index_users_on_username_slug", unique: true
  end

  add_foreign_key "authentications", "users"
  add_foreign_key "posts", "users"
end
