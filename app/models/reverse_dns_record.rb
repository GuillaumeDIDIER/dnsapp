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

#Modules used to create ReverseDnsRecords mixins

#Type SOA records should extend this
module ReverseDnsSoaRecord
  attr_accessor :r_primary_ns, :r_resp_person, :r_serial, :r_refresh, :r_retry, :r_expire, :r_minimum

  #Modifications made when adding this module
  def self.extended(base)
    base.rtype = 'SOA'
    base.retrieve_attributes

    #Forbid further modification on this field
    def base.rtype=(rtype)
    end
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
module ReverseDnsNsRecord

  #Modifications made when adding this module
  def self.extended(base)
    base.rtype = 'NS'

    #Forbid further modification on this field
    def base.rtype=(rtype)
    end
  end

  private

    def build_record
      #Nothing much to do
    end
end

#Type PTR records should extend this
module ReverseDnsPtrRecord

  #Modifications made when adding this module
  def self.extended(base)
    base.rtype = 'PTR'

    #Forbid further modification on this field
    def base.rtype=(rtype)
    end
  end

  private

    def build_record
      #Nothing much to do
    end
end

#Validator
class ReverseDnsValidator < ActiveModel::Validator
  def validate(record)
    host_regex = /\A(?:\d{1,3}|@)\z/
    zone_regex = /\A(?:\d{1,3}\.){1,3}in-addr.arpa\z/

    ptr_regex = /\A[a-z](?:-?[a-z0-9])+\.[a-z](?:\.?[a-z0-9])+\.[a-z]{2,3}\.\z/i

    #Bad coding practice: I put validation here so that error messages are localized.
    #I didn't want to use localization modules though.
    record.errors[:ttl]   << "ne doit pas être vide" if record.ttl.blank?
    record.errors[:host]  << "n'est pas valide"  unless record.host.match host_regex
    record.errors[:zone]  << "n'est pas valide"  unless record.zone.match zone_regex
    record.errors[:rtype] << "ne doit pas être vide" if record.rtype.blank?
    record.errors[:data]  << "ne doit pas être vide" if record.data.blank?

    #Unicity check
    twin = ReverseDnsRecord.where( :host => record.host, :zone => record.zone, :rtype => record.rtype, :data => record.data ).first
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
    elsif record.rtype == "PTR"
      record.errors[:host] << "'@' est interdit"             if record.host == "@"
      record.errors[:data] << "n'est pas une adresse valide" unless record.data.match ptr_regex
    else
      record.errors[:rtype] << "non valide"
    end
  end
end

#Generic class. Use mixins with above modules
class ReverseDnsRecord < ActiveRecord::Base
  set_table_name "reverse_dns"
  set_primary_key "rid"

  attr_accessible :ttl, :rtype, :host, :zone, :data

  validates_with ReverseDnsValidator

  before_validation :build_record

  def self.default_ttl
    return 3200
  end

  def self.new_soa
    record = ReverseDnsRecord.new
    record.ttl = ReverseDnsRecord.default_ttl
    record.extend ReverseDnsSoaRecord
    return record
  end

  def self.new_ns
    record = ReverseDnsRecord.new
    record.ttl = ReverseDnsRecord.default_ttl
    record.extend ReverseDnsNsRecord
    return record
  end

  def self.new_ptr
    record = ReverseDnsRecord.new
    record.ttl = ReverseDnsRecord.default_ttl
    record.extend ReverseDnsPtrRecord
    return record
  end

  def auto_cast
    if rtype == "SOA"
      self.extend ReverseDnsSoaRecord
      self.retrieve_attributes
    elsif rtype == "NS"
      self.extend ReverseDnsNsRecord
    elsif rtype == "PTR"
      self.extend ReverseDnsPtrRecord
    end
  end

  private

    def build_record
      raise "Must use specific builder"
    end
end
