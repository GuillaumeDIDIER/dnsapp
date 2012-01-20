# encoding: utf-8

#Modules used to create DnsRecords mixins

#Type SOA records should extend this
module DnsSoaRecord
  attr_accessor :r_primary_ns, :r_resp_person, :r_serial, :r_refresh, :r_retry, :r_expire, :r_minimum

  #Forbid further modification on this field
  def rtype=(rtype)
  end

  def retrieve_attributes
    unless self.data.nil?
      t = self.data.split(" ")

      self.r_primary_ns  = t[0]
      self.r_resp_person = t[1]
      self.r_serial      = t[2]
      self.r_refresh     = t[3]
      self.r_retry       = t[4]
      self.r_expire      = t[5]
      self.r_minimum     = t[6]
    end
  end

  def increment_serial
    unless self.r_serial.nil?
      s = 1 + self.r_serial.to_i
      self.r_serial = s.to_s
    end
  end

  private

    def build_record
      self.data = ""
      self.data =        self.r_primary_ns  unless self.r_primary_ns.nil?
      self.data += " " + self.r_resp_person unless self.r_resp_person.nil?
      self.data += " " + self.r_serial      unless self.r_serial.nil?
      self.data += " " + self.r_refresh     unless self.r_refresh.nil?
      self.data += " " + self.r_retry       unless self.r_retry.nil?
      self.data += " " + self.r_expire      unless self.r_expire.nil?
      self.data += " " + self.r_minimum     unless self.r_minimum.nil?
    end
end

#Validator
class DnsValidator < ActiveModel::Validator
  def validate(record)
    
     host_regex = /\A(?:[a-z](?:-?[a-z0-9])+|@)\z/i
     zone_regex = /\A[a-z](?:\.?[a-z0-9])+\.[a-z]{2,3}\z/i

     record.errors[:ttl]   << "ne doit pas être vide" if record.ttl.nil?
     record.errors[:host]  << "n'est pas valide"  unless record.host.match host_regex
     record.errors[:zone]  << "n'est pas valide"  unless record.zone.match zone_regex
     record.errors[:rtype] << "ne doit pas être vide" if record.rtype.nil?
     record.errors[:data]  << "ne doit pas être vide" if record.data.nil?

    if record.rtype = "SOA"
      record.errors[:data] << "doit contenir le NS principal" if record.r_primary_ns.nil?
      record.errors[:data] << "doit contenir le responsable"  if record.r_resp_person.nil?
      record.errors[:data] << "doit contenir le serial"       if record.r_serial.nil?
      record.errors[:data] << "doit contenir le refresh"      if record.r_refresh.nil?
      record.errors[:data] << "doit contenir le retry"        if record.r_retry.nil?
      record.errors[:data] << "doit contenir le expire"       if record.r_expire.nil?
      record.errors[:data] << "doit contenir le minimum"      if record.r_minimum.nil?
    else
      record.errors[:rtype] << "non valide"
    end
  end
end

#Generic class. Use mixins with above modules
class DnsRecord < ActiveRecord::Base
  set_table_name "DNS"
  set_primary_key "rid"

  host_regex = /\A(?:[a-z](?:-?[a-z0-9])+|@)\z/i

  attr_accessible :ttl, :rtype, :host, :zone, :data

  #validates :ttl,   :presence => true
  #validates :host,  :presence => true,
  #                  :format   => { :with => host_regex }
  #validates :zone,  :presence => true
  #validates :rtype, :presence => true
  #validates :data,  :presence => true

  validates_with DnsValidator

  before_validation :build_record

  def self.default_ttl
    return 3200
  end

  def self.new_soa
    record = DnsRecord.new
    record.ttl = DnsRecord.default_ttl
    record.rtype = "SOA"
    record.extend DnsSoaRecord
    return record
  end

  private

    def build_record
      raise "Must use specific builder"
    end
end
