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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130625133919) do

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "authentications", ["provider", "uid"], :name => "index_authentications_on_provider_and_uid"
  add_index "authentications", ["user_id", "provider"], :name => "index_authentications_on_user_id_and_provider", :unique => true

  create_table "facebook_lists", :force => true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "photo_url"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "page_id"
  end

  add_index "facebook_lists", ["page_id"], :name => "index_facebook_lists_on_page_id"
  add_index "facebook_lists", ["user_id", "created_at"], :name => "index_facebook_lists_on_user_id_and_created_at"

  create_table "fb_top_engages", :force => true do |t|
    t.integer  "day"
    t.integer  "page_id"
    t.string   "page_fb_id"
    t.integer  "fan_count"
    t.integer  "variation"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "talking_about_count"
  end

  add_index "fb_top_engages", ["day", "page_id"], :name => "index_fb_top_engages_on_day_and_page_id", :unique => true
  add_index "fb_top_engages", ["day"], :name => "index_fb_top_engages_on_day"
  add_index "fb_top_engages", ["page_id"], :name => "index_fb_top_engages_on_page_id"

  create_table "list_page_relationships", :force => true do |t|
    t.integer  "list_id"
    t.integer  "page_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "list_page_relationships", ["list_id", "page_id"], :name => "index_list_page_relationships_on_list_id_and_page_id", :unique => true
  add_index "list_page_relationships", ["list_id"], :name => "index_list_page_relationships_on_list_id"
  add_index "list_page_relationships", ["page_id"], :name => "index_list_page_relationships_on_page_id"

  create_table "page_data_days", :force => true do |t|
    t.integer  "page_id"
    t.integer  "likes"
    t.integer  "prosumers"
    t.integer  "comments"
    t.integer  "shared"
    t.integer  "total_likes_stream"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "day"
    t.integer  "posts"
  end

  add_index "page_data_days", ["day"], :name => "index_page_data_days_on_day"
  add_index "page_data_days", ["page_id", "day"], :name => "index_page_data_days_on_page_id_and_day", :unique => true
  add_index "page_data_days", ["page_id"], :name => "index_page_data_days_on_page_id"

  create_table "page_relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "competitor_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "page_relationships", ["competitor_id"], :name => "index_page_relationships_on_competitor_id"
  add_index "page_relationships", ["follower_id", "competitor_id"], :name => "index_page_relationships_on_follower_id_and_competitor_id", :unique => true
  add_index "page_relationships", ["follower_id"], :name => "index_page_relationships_on_follower_id"

  create_table "page_streams", :force => true do |t|
    t.integer  "page_id"
    t.string   "post_id"
    t.string   "permalink"
    t.string   "media_type"
    t.string   "actor_id"
    t.string   "target_id"
    t.integer  "likes_count"
    t.integer  "comments_count"
    t.integer  "share_count"
    t.integer  "created_time"
    t.integer  "day"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "page_streams", ["actor_id"], :name => "index_page_streams_on_actor_id"
  add_index "page_streams", ["day"], :name => "index_page_streams_on_day"
  add_index "page_streams", ["media_type"], :name => "index_page_streams_on_media_type"
  add_index "page_streams", ["page_id", "day"], :name => "index_page_streams_on_page_id_and_day"
  add_index "page_streams", ["page_id", "media_type"], :name => "index_page_streams_on_page_id_and_media_type"
  add_index "page_streams", ["page_id"], :name => "index_page_streams_on_page_id"

  create_table "pages", :force => true do |t|
    t.string   "page_id"
    t.string   "name"
    t.string   "page_type"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "fan_count"
    t.integer  "talking_about_count"
  end

  add_index "pages", ["page_id"], :name => "index_pages_on_page_id", :unique => true

  create_table "user_page_relationships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "page_id"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "active",     :default => false
  end

  add_index "user_page_relationships", ["page_id"], :name => "index_user_page_relationships_on_page_id"
  add_index "user_page_relationships", ["user_id", "page_id"], :name => "index_user_page_relationships_on_user_id_and_page_id", :unique => true
  add_index "user_page_relationships", ["user_id"], :name => "index_user_page_relationships_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "remember_token"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
