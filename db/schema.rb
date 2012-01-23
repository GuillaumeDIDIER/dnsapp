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

ActiveRecord::Schema.define(:version => 20120122001130) do

  create_table "dns", :id => false, :force => true do |t|
    t.integer "rid",                                  :null => false
    t.integer "ttl"
    t.string  "host",  :limit => 100, :default => "", :null => false
    t.string  "zone",  :limit => 100, :default => "", :null => false
    t.string  "rtype", :limit => 10,  :default => "", :null => false
    t.string  "data",                 :default => "", :null => false
  end

  add_index "dns", ["rid"], :name => "rid", :unique => true
  add_index "dns", ["rtype"], :name => "rtype"

  create_table "privileged_users", :force => true do |t|
    t.string   "name"
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin"
    t.integer  "dns_zone_id"
    t.boolean  "unauthorized_names"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "privileged_users", ["name"], :name => "index_privileged_users_on_name", :unique => true

  create_table "reverse_dns", :id => false, :force => true do |t|
    t.integer "rid",                                  :null => false
    t.integer "ttl"
    t.string  "host",  :limit => 100, :default => "", :null => false
    t.string  "zone",  :limit => 100, :default => "", :null => false
    t.string  "rtype", :limit => 10,  :default => "", :null => false
    t.string  "data",                 :default => "", :null => false
  end

  add_index "reverse_dns", ["rid"], :name => "rid", :unique => true
  add_index "reverse_dns", ["rtype"], :name => "rtype"

  create_table "unauthorized_names", :force => true do |t|
    t.string   "name"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "unauthorized_names", ["name"], :name => "index_unauthorized_names_on_name", :unique => true

  create_table "zones", :force => true do |t|
    t.string   "zone"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "zones", ["zone"], :name => "index_zones_on_zone", :unique => true

end
