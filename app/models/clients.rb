# encoding: utf-8
class Clients < ActiveRecord::Base
  set_table_name "clients"

  attr_accessible :username, :lastip, :status
end
