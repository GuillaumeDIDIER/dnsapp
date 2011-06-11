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

ActiveRecord::Schema.define(:version => 20110611080215) do

  create_table "DNS", :force => true do |t|
    t.string   "name",                     :default => "", :null => false
    t.integer  "ttl"
    t.string   "rdtype",     :limit => 10, :default => "", :null => false
    t.string   "rdata",                    :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "DNS_backup", :id => false, :force => true do |t|
    t.string  "name",   :limit => 100, :default => "", :null => false
    t.integer "ttl"
    t.string  "rdtype", :limit => 10,  :default => "", :null => false
    t.string  "rdata",                 :default => "", :null => false
  end

  create_table "clients", :force => true do |t|
    t.string    "iconid",      :limit => 8
    t.string    "username",    :limit => 64, :default => "", :null => false
    t.string    "password",    :limit => 64, :default => "", :null => false
    t.string    "lastip",      :limit => 16
    t.timestamp "timestamp",                                 :null => false
    t.integer   "status",      :limit => 2,  :default => 0,  :null => false
    t.integer   "isconnected", :limit => 1,  :default => 0,  :null => false
    t.integer   "options",                   :default => 0,  :null => false
    t.integer   "version",                   :default => 0,  :null => false
  end

  add_index "clients", ["id"], :name => "id", :unique => true
  add_index "clients", ["lastip"], :name => "lastip"
  add_index "clients", ["username"], :name => "username"

  create_table "dns_records", :id => false, :force => true do |t|
    t.text    "zone",                     :null => false
    t.text    "host"
    t.text    "type"
    t.text    "data",                     :null => false
    t.integer "ttl"
    t.text    "mx_priority"
    t.integer "refresh"
    t.integer "retry"
    t.integer "expire"
    t.integer "minimum"
    t.integer "serial",      :limit => 8
    t.text    "resp_person"
    t.text    "primary_ns"
  end

  add_index "dns_records", ["host"], :name => "host_index", :length => {"host"=>20}
  add_index "dns_records", ["type"], :name => "type_index", :length => {"type"=>8}
  add_index "dns_records", ["zone"], :name => "zone_index", :length => {"zone"=>30}

  create_table "privileged_users", :force => true do |t|
    t.string   "name"
    t.string   "encrypted_password"
    t.string   "salt"
    t.boolean  "admin"
    t.integer  "dns"
    t.integer  "alias"
    t.integer  "users"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "privileged_users", ["name"], :name => "index_privileged_users_on_name", :unique => true

  create_table "reverse_DNS", :id => false, :force => true do |t|
    t.string  "name",   :limit => 100, :default => "", :null => false
    t.integer "ttl"
    t.string  "rdtype", :limit => 10,  :default => "", :null => false
    t.string  "rdata",                 :default => "", :null => false
  end

  create_table "reverse_DNS_backup", :id => false, :force => true do |t|
    t.string  "name",   :limit => 100, :default => "", :null => false
    t.integer "ttl"
    t.string  "rdtype", :limit => 10,  :default => "", :null => false
    t.string  "rdata",                 :default => "", :null => false
  end

  create_table "reverse_dns", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reverse_dns_models", :force => true do |t|
    t.string   "name",       :limit => 100, :default => "", :null => false
    t.integer  "ttl"
    t.string   "rdtype",     :limit => 10,  :default => "", :null => false
    t.string   "rdata",                     :default => "", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "serial_models", :force => true do |t|
    t.string   "nom",        :limit => 64, :default => "", :null => false
    t.integer  "valeur",                   :default => 0,  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "serials", :primary_key => "nom", :force => true do |t|
    t.integer "valeur", :default => 0, :null => false
  end

  create_table "serials_backup", :primary_key => "nom", :force => true do |t|
    t.integer "valeur", :default => 0, :null => false
  end

  create_table "software", :primary_key => "version", :force => true do |t|
    t.integer "capabilities",               :default => 0,  :null => false
    t.string  "name",         :limit => 64, :default => "", :null => false
  end

  create_table "versions", :primary_key => "Client", :force => true do |t|
    t.text    "ClientName"
    t.integer "MajorVersion", :default => 0, :null => false
    t.integer "MinorVersion", :default => 0, :null => false
    t.integer "FunnyVersion", :default => 0, :null => false
  end

  create_table "xfr_table", :id => false, :force => true do |t|
    t.text "zone",   :null => false
    t.text "client", :null => false
  end

  add_index "xfr_table", ["zone", "client"], :name => "zone_client_index", :length => {"zone"=>30, "client"=>20}

end
