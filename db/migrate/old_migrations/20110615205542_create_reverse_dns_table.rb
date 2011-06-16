class CreateReverseDnsTable < ActiveRecord::Migration
  def self.up
    create_table :reverse_dns_ror do |t|
      t.string :name
      t.integer :ttl
      t.string :rdtype
      t.string :rdata

      t.timestamps
    end
  end

    #initialise avec les valeurs de la table pas bien
    #ReverseDns.all.each do |dns|
     # dnsm = ReverseDomainName.new
      #dnsm.name = dns.name
      #dnsm.ttl = dns.ttl
      #dnsm.rdtype = dns.rdtype
      #dnsm.rdata = dns.rdata
      #dnsm.save
    #end

  def self.down
    drop_table :reverse_dns_ror
  end
end
