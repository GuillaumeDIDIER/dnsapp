# encoding: utf-8
class ReverseDns < ActiveRecord::Base
  #set_table_name "reverse_dns_models"
  set_table_name "reverse_DNS"
  set_primary_key "name"
  
  attr_accessible :name, :ttl, :rdtype, :rdata

end
