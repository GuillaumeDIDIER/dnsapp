class CopyRdns < ActiveRecord::Migration
  def self.up

  #initialise avec les valeurs de la table pas bien
  ReverseDns.all.each do |dns|
    dnsm = ReverseDomainName.new
    dnsm.name = dns.name
    dnsm.ttl = dns.ttl
    dnsm.rdtype = dns.rdtype
    dnsm.rdata = dns.rdata
    dnsm.save
  end

  end

  def self.down
  end
end
