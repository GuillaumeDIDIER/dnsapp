# encoding: utf-8
class DnsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    doubles = DomainName.where :name => value
    same = true
    same = false if doubles.count > 0
    doubles.each do |dns|
      same = true if dns.id == record.id
    end
    short_name = value.match(DomainName.short_name_from_name_regex).to_s
    record.errors[:short_name] << "#{short_name} existe déjà (associé à #{doubles.first.rdata})" unless same

    #Noms non authorisés
    record.errors[:short_name] << "#{short_name} est interdit" unless Admin::UnauthorizedName.find_by_name(short_name).nil?
  
    #Noms du réseau école
    unauthorized = system( "host '#{short_name}'" )
    record.errors[:short_name] << "#{short_name} existe déjà sur le réseau de l'école" if unauthorized
  end
end


class DomainName < ActiveRecord::Base
  set_table_name "DNS"
  set_primary_key "rid"

  # Format de nom : commence par un lettre,
  # caractères alphanumériques et tiret.
  # On interdit '--' (deux tirets à la suite).
  name_regex = /\A[a-z](?:-?[a-z0-9])+\z/i

  attr_accessor :short_name, :short_dest
  attr_accessible :name, :ttl, :rdtype, :rdata, :short_name

  validates :short_name, :presence => true,
                         :format   => { :with => name_regex }
  validates :name, :dns => true
  validates :rdtype, :presence => true
  validates :rdata, :presence => true
  validates :ttl, :presence => true

  before_validation :create_dns

  def self.new_dns(short_name, ip)
    dns = DomainName.new
    dns.short_name = short_name
    dns.rdtype = "A"
    dns.rdata = ip
    return dns
  end

  def self.new_alias(short_name, short_dest)
    dns = DomainName.new
    dns.short_name = short_name
    dns.rdtype = "Cname"
    dns.rdata = "#{short_dest}.#{suffix}."
    dest = DomainName.find_by_name "#{short_dest}.#{suffix}"
    dns = nil if dest.nil?
    return dns
  end

  def update_dest
    dest = DomainName.find_by_name "#{self.short_dest}.#{DomainName.suffix}"
    self.rdata = "#{self.short_dest}.#{DomainName.suffix}."
    self.rdata = nil if dest.nil?
  end

  def self.suffix
    "eleves.polytechnique.fr"
  end

  def get_short_name
    self.short_name ||= self.name.match(DomainName.short_name_from_name_regex)
  end

  def get_name_from_short_name
    self.name = "#{self.short_name}.#{DomainName.suffix}"
  end

  def get_short_dest
    self.short_dest ||= self.rdata.match(DomainName.short_name_from_name_regex)
  end

  def self.short_name_from_name_regex
    /\A[a-z](?:-?[a-z0-9])+/i
  end

  private

    def create_dns
      self.get_short_name
      self.get_name_from_short_name
      self.ttl = 3200
    end

end
