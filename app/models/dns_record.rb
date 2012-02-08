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
      match_data = self.r_serial.match DnsSoaRecord.serial_regex
      #We would like to use date format serials
      if !match_data.nil?
        now = Time.now.utc

        #New serial will be issued today
        y = "%04d" % now.year
        m = "%02d" % now.month
        d = "%02d" % now.day

        #If old serial corresponds to a date in the future
        #we only increment n
        if match_data[1] > y or
          ( match_data[1] == y and match_data[2] > m ) or
          ( match_data[1] == y and match_data[2] == m and match_data[3] > d )

          y = match_data[1]
          m = match_data[2]
          d = match_data[3]
        end

        #We keep the last numbers to increment them
        n = match_data[4]
        new_serial = "#{y}#{m}#{d}#{n}"

        #If the old serial was not issued this day, set n = 0
        #With a trick: serial will be incremented later
        if new_serial != self.r_serial
          n = 99
          d = "#{d.to_i - 1}"
	  d = "%02d" % d
        end
        
        #Finally, set the serial
        self.r_serial = "#{y}#{m}#{d}#{n}"
      end
      s = 1 + self.r_serial.to_i
      self.r_serial = s.to_s
    end
  end

  def init_serial
    now = Time.now.utc
    y = "%04d" % now.year
    m = "%02d" % now.month
    d = "%02d" % now.day
    self.r_serial = "#{y}#{m}#{d}00"
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

    def self.serial_regex
      /\A(\d{4})(\d{2})(\d{2})(\d{2})\z/
    end
end

#Type NS records should extend this
module DnsNsRecord

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

#Type MX records should extend this
module DnsMxRecord
  attr_accessor :r_mx_priority, :r_data

  #Modifications made when adding this module
  def self.extended(base)
    base.rtype = 'MX'
    base.retrieve_attributes

    #Forbid further modification on this field
    def base.rtype=(rtype)
    end
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

  #Modifications made when adding this module
  def self.extended(base)
    base.rtype = 'A'

    #Forbid further modification on this field
    def base.rtype=(rtype)
    end
  end

  private

    def build_record
      #Nothing much to do
    end
end

#Type CNAME records should extend this
module DnsCnameRecord

  #Modifications made when adding this module
  def self.extended(base)
    base.rtype = 'CNAME'

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
class DnsValidator < ActiveModel::Validator
  def validate(record)
    host_regex = /\A(?:[a-z0-9](?:-?[a-z0-9]){2,}|@)\z/i
    zone_regex = /\A[a-z](?:\.?[a-z0-9])+\.[a-z]{2,3}\z/i

    #Bad coding practice: I put validation here so that error messages are localized.
    #I didn't want to use localization modules though.
    record.errors[:ttl  ].insert( -1, "ne doit pas être vide" )      if record.ttl.blank?
    record.errors[:host ].insert( -1, "n'est pas valide"      )  unless record.host.match host_regex
    record.errors[:zone ].insert( -1, "n'est pas valide"      )  unless record.zone.match zone_regex
    record.errors[:rtype].insert( -1, "ne doit pas être vide" )      if record.rtype.blank?
    record.errors[:data ].insert( -1, "ne doit pas être vide" )      if record.data.blank?

    #Unicity check
    twin = DnsRecord.where( :host => record.host, :zone => record.zone, :rtype => record.rtype, :data => record.data ).first
    if !twin.nil?
      record.errors[:data].insert( -1,  "la même entrée existe déjà" ) unless record.rid == twin.rid
    end

    if record.rtype == "SOA"
      record.errors[:data].insert( -1, "doit contenir le NS principal" ) if record.r_primary_ns.blank?
      record.errors[:data].insert( -1, "doit contenir le responsable"  ) if record.r_resp_person.blank?
      record.errors[:data].insert( -1, "doit contenir le serial"       ) if record.r_serial.blank?
      record.errors[:data].insert( -1, "doit contenir le refresh"      ) if record.r_refresh.blank?
      record.errors[:data].insert( -1, "doit contenir le retry"        ) if record.r_retry.blank?
      record.errors[:data].insert( -1, "doit contenir le expire"       ) if record.r_expire.blank?
      record.errors[:data].insert( -1, "doit contenir le minimum"      ) if record.r_minimum.blank?
    elsif record.rtype == "NS"
      #Nothing more to check
    elsif record.rtype == "MX"
      record.errors[:data].insert( -1, "doit contenir la MX priority" ) if record.r_mx_priority.blank?
      record.errors[:data].insert( -1, "doit contenir le serveur MX"  ) if record.r_data.blank?

    elsif record.rtype == "A"
      record.errors[:host].insert( -1, "'@' est interdit"                )     if record.host == "@"
      record.errors[:data].insert( -1, "n'est pas une adresse ip valide" ) unless ip_addr? record.data
    elsif record.rtype == "CNAME"
      record.errors[:host].insert( -1, "'@' est interdit" ) if record.host == "@"
    else
      record.errors[:rtype].insert( -1, "non valide" )
    end

    #Check for duplicates in zone
    if record.rtype == "A" or record.rtype == "CNAME"
      duplicates = DnsRecord.find( :all, :conditions => ["(rtype = 'A' or rtype = 'CNAME') and host = ? and zone = ?", record.host, record.zone] )
      ok = true
      ok = false if duplicates.count > 0
      duplicates.each do |dup|
        ok = true if dup.id == record.id
      end

      record.errors[:host].insert( -1, "existe déjà dans cette zone" ) unless ok
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
  set_table_name "dns"
  set_primary_key "rid"

  attr_accessible :ttl, :rtype, :host, :zone, :data

  validates_with DnsValidator

  before_validation :build_record

  def self.default_ttl
    return 3200
  end

  def self.new_record(params)
    record = DnsRecord.new(params)
    record.ttl = DnsRecord.default_ttl
    record.auto_cast
    return record
  end

  def self.new_soa
    record = DnsRecord.new
    record.ttl = DnsRecord.default_ttl
    record.extend DnsSoaRecord
    return record
  end

  def self.new_ns
    record = DnsRecord.new
    record.ttl = DnsRecord.default_ttl
    record.extend DnsNsRecord
    return record
  end

  def self.new_mx
    record = DnsRecord.new
    record.ttl = DnsRecord.default_ttl
    record.extend DnsMxRecord
    return record
  end

  def self.new_a
    record = DnsRecord.new
    record.ttl = DnsRecord.default_ttl
    record.extend DnsARecord
    return record
  end

  def self.new_cname
    record = DnsRecord.new
    record.ttl = DnsRecord.default_ttl
    record.extend DnsCnameRecord
    return record
  end

  def auto_cast
    if rtype == "SOA"
      self.extend DnsSoaRecord
      self.retrieve_attributes
    elsif rtype == "NS"
      self.extend DnsNsRecord
    elsif rtype == "MX"
      self.extend DnsMxRecord
      self.retrieve_attributes
    elsif rtype == "A"
      self.extend DnsARecord
    elsif rtype == "CNAME"
      self.extend DnsCnameRecord
    end
  end

  #Run this for user-made A and CNAME Records
  def check_host
    Admin::UnauthorizedName.all.each do |uname|
      if !uname.regex.nil? and self.host.match uname.regex
        self.errors[:host].insert( -1, "est interdit" )
        return false
      end
    end

    return true
  end

  private

    def build_record
      raise "Must use specific builder"
    end
end
