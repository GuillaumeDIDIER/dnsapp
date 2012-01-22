# encoding: utf-8

#Author: Johann-Michael THIEBAUT <johann.thiebaut@gmail.com>
#In this project, models do not enforce any policy regarding field values.
#Validation only checks consistency of data to some extend to match DNS standards
#and current named/bind configuration.
#Thus anyone who runs the rails console is able to inject invalid values in
#the database AT HIS OWN RISK. (Anyway this is still possible via mysql console)
#This policy allows flexibility for future development of both the DNS architecture and
#web application overlay (=this Ruby on Rails application).
#Verification is delegated to controllers.
#Typical scenario is creating multiple controllers should allow users to define their
#domain name in specific zones, with ip validation.

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

#Type NS records should extend this
module DnsNsRecord
  #Forbid further modification on this field
  def rtype=(rtype)
  end

  private

    def build_record
      #Nothing much to do
    end
end

#Type MX records should extend this
module DnsMxRecord
  attr_accessor :r_mx_priority, :r_data

  #Forbid further modification on this field
  def rtype=(rtype)
  end

  def retrieve_attributes
    unless self.data.nil?
      t = self.data.split(" ")

      self.r_mx_priority = t[0]
      self.r_data        = t[1]
    end
  end

  private

    def build_record
      self.data = ""
      self.data =        self.r_mx_priority unless self.r_mx_priority.nil?
      self.data += " " + self.r_data        unless self.r_data.nil?
    end 
end

#Type A records should extend this
module DnsARecord
  #Forbid further modification on this field
  def rtype=(rtype)
  end

  private

    def build_record
      #Nothing much to do
    end
end

#Type CNAME records should extend this
module DnsCnameRecord
  #Forbid further modification on this field
  def rtype=(rtype)
  end

  private

    def build_record
      #Nothing much to do
    end
end

#Validator
class DnsValidator < ActiveModel::Validator
  def validate(record)
    host_regex = /\A(?:[a-z](?:-?[a-z0-9])+|@)\z/i
    zone_regex = /\A[a-z](?:\.?[a-z0-9])+\.[a-z]{2,3}\z/i

    #Bad coding practice: I put validation here so that error messages are localized.
    #I didn't want to use localization modules though.
    record.errors[:ttl]   << "ne doit pas être vide" if record.ttl.blank?
    record.errors[:host]  << "n'est pas valide"  unless record.host.match host_regex
    record.errors[:zone]  << "n'est pas valide"  unless record.zone.match zone_regex
    record.errors[:rtype] << "ne doit pas être vide" if record.rtype.blank?
    record.errors[:data]  << "ne doit pas être vide" if record.data.blank?

    #Unicity check
    twin = DnsRecord.where( :host => record.host, :zone => record.zone, :rtype => record.rtype, :data => record.data ).first
    if !twin.nil?
      record.errors[:data] << "la même entrée existe déjà" unless record.rid == twin.rid
    end

    if record.rtype == "SOA"
      record.errors[:data] << "doit contenir le NS principal" if record.r_primary_ns.blank?
      record.errors[:data] << "doit contenir le responsable"  if record.r_resp_person.blank?
      record.errors[:data] << "doit contenir le serial"       if record.r_serial.blank?
      record.errors[:data] << "doit contenir le refresh"      if record.r_refresh.blank?
      record.errors[:data] << "doit contenir le retry"        if record.r_retry.blank?
      record.errors[:data] << "doit contenir le expire"       if record.r_expire.blank?
      record.errors[:data] << "doit contenir le minimum"      if record.r_minimum.blank?
    elsif record.rtype == "NS"
      #Nothing more to check
    elsif record.rtype == "MX"
      record.errors[:data] << "doit contenir la MX priority" if record.r_mx_priority.blank?
      record.errors[:data] << "doit contenir la cible"       if record.r_data.blank?
    elsif record.rtype == "A"
      record.errors[:host] << "'@' est interdit"                if record.host == "@"
      record.errors[:data] << "n'est pas une adresse ip valide" unless ip_addr? record.data
    elsif record.rtype == "CNAME"
      record.errors[:host] << "'@' est interdit"                if record.host == "@"
    else
      record.errors[:rtype] << "non valide"
    end
  end

  #Returns true if it is an ipv4 adress.
  #Only verify format, not value
  def ip_addr?(ip)
    ip_tab = []
    ip.each('.') { |sub| ip_tab.insert(-1, sub.to_i) }
    valid = true
    valid = false unless ip_tab.count == 4
    for i in 0..3
      valid = false unless (0..255).member? ip_tab[i]
    end
    return valid
  end
end

#Generic class. Use mixins with above modules
class DnsRecord < ActiveRecord::Base
  set_table_name "DNS"
  set_primary_key "rid"

  host_regex = /\A(?:[a-z](?:-?[a-z0-9])+|@)\z/i

  attr_accessible :ttl, :rtype, :host, :zone, :data

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

  def self.new_ns
    record = DnsRecord.new
    record.ttl = DnsRecord.default_ttl
    record.rtype = "NS"
    record.extend DnsNsRecord
    return record
  end

  def self.new_mx
    record = DnsRecord.new
    record.ttl = DnsRecord.default_ttl
    record.rtype = "MX"
    record.extend DnsMxRecord
    return record
  end

  def self.new_a
    record = DnsRecord.new
    record.ttl = DnsRecord.default_ttl
    record.rtype = "A"
    record.extend DnsARecord
    return record
  end

  def self.new_cname
    record = DnsRecord.new
    record.ttl = DnsRecord.default_ttl
    record.rtype = "CNAME"
    record.extend DnsCnameRecord
    return record
  end

  private

    def build_record
      raise "Must use specific builder"
    end
end
