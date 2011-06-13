# encoding: utf-8
class DnsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    doubles = DomainName.where :name => value
    same = true
    same = false if doubles.count > 0
    doubles.each do |dns|
      same = true if dns.id == record.id
    end
    record.errors[:short_name] << "#{value.match(short_name_from_name_regex)} existe déjà (associé à #{doubles.first.rdata})" unless same
  end
end


class DomainName < ActiveRecord::Base
  set_table_name "DNS"

  # Format de nom : commence par un lettre,
  # caractères alphanumériques et tiret.
  # On interdit '--' (deux tirets à la suite).
  name_regex = /\A[a-z](?:-?[a-z0-9])+\z/i

  attr_accessor :short_name
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

  def suffix
    "eleves.polytechnique.fr"
  end

  def get_short_name
    self.short_name ||= self.name.match(short_name_from_name_regex)
  end

  private

    def create_dns
      self.get_short_name
      self.name = "#{self.short_name}.#{suffix}"
      self.ttl = 3200
    end

end
