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

ActiveRecord::Schema.define(:version => 20130226185641) do

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "authentications", ["user_id", "provider"], :name => "index_authentications_on_user_id_and_provider", :unique => true

  create_table "engagements", :force => true do |t|
    t.integer  "page_id"
    t.date     "date"
    t.integer  "likes"
    t.integer  "prosumers"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "engagements", ["page_id", "date"], :name => "index_engagements_on_page_id_and_date", :unique => true

  create_table "page_relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "competitor_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "page_relationships", ["competitor_id"], :name => "index_page_relationships_on_competitor_id"
  add_index "page_relationships", ["follower_id", "competitor_id"], :name => "index_page_relationships_on_follower_id_and_competitor_id", :unique => true
  add_index "page_relationships", ["follower_id"], :name => "index_page_relationships_on_follower_id"

  create_table "pages", :force => true do |t|
    t.string   "page_id"
    t.string   "name"
    t.string   "page_type"
    t.string   "username"
    t.string   "page_url"
    t.string   "pic_square"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "pages", ["page_id"], :name => "index_pages_on_page_id", :unique => true

  create_table "user_page_relationships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "page_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
