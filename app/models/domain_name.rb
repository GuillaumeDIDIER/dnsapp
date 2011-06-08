class DnsValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    double = DomainName.where :name => value
    regex = /\A[a-z](?:-?[a-z0-9])+/i
    record.errors[:short_name] << " : #{value.match(regex)} existe déjà (associé à #{double.first.rdata})" if double.any?
  end
end


class DomainName < ActiveRecord::Base
  set_table_name "DNS"

  # Format de nom : commence par un lettre,
  # caractères alphanumériques et tiret.
  # On interdit '--'.
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
    dns
  end

  def suffix
    "eleves.polytechnique.fr"
  end

  private

    def create_dns
      self.name = "#{self.short_name}.#{suffix}"
      self.ttl = 3200
    end

end
