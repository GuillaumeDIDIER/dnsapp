# encoding: utf-8
class ReverseDomainName < ActiveRecord::Base
  set_table_name "reverse_dns_models"
  #set_table_name "reverse_DNS"
  
  attr_accessible :name, :ttl, :rdtype, :rdata

  validates :name, :presence => true
  validates :rdtype, :presence => true
  validates :rdata, :presence => true
  validates :ttl, :presence => true

  before_validation :create_rdns

  def self.new_rdns(name, ip)
    rdns = ReverseDomainName.new
    regex = /\A(\d+)\.(\d+)\.(\d+)\.(\d+)\z/
    rip = ip.gsub(regex, "\\4.\\3.\\2.\\1")
    rdns.name = "#{rip}.in-addr.arpa"
    rdns.rdtype = "PTR"
    rdns.rdata = "#{name}."
    rdns
  end

  private

    def create_rdns
      self.ttl = 3200
    end

end
