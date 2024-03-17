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

ActiveRecord::Schema[7.1].define(version: 20_240_314_060_450) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'likes', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.bigint 'post_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['post_id'], name: 'index_likes_on_post_id'
    t.index %w[user_id post_id], name: 'index_likes_on_user_id_and_post_id', unique: true
    t.index ['user_id'], name: 'index_likes_on_user_id'
  end

  create_table 'posts', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.text 'content', null: false
    t.string 'audio_url'
    t.integer 'privacy', default: 0, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['user_id'], name: 'index_posts_on_user_id'
  end

  create_table 'relationships', force: :cascade do |t|
    t.bigint 'follower_id', null: false
    t.bigint 'followed_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['followed_id'], name: 'index_relationships_on_followed_id'
    t.index %w[follower_id followed_id], name: 'index_relationships_on_follower_id_and_followed_id', unique: true
    t.index ['follower_id'], name: 'index_relationships_on_follower_id'
  end

  create_table 'users', force: :cascade do |t|
    t.string 'display_name'
    t.string 'username_slug'
    t.string 'email', null: false
    t.string 'password_digest', null: false
    t.text 'self_introduction'
    t.string 'avatar_url'
    t.string 'provider'
    t.string 'uid'
    t.string 'access_token'
    t.string 'refresh_token'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['email'], name: 'index_users_on_email', unique: true
  end

  add_foreign_key 'likes', 'posts'
  add_foreign_key 'likes', 'users'
  add_foreign_key 'posts', 'users'
  add_foreign_key 'relationships', 'users', column: 'followed_id'
  add_foreign_key 'relationships', 'users', column: 'follower_id'
end
