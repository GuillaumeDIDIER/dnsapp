class CreateDnsModels < ActiveRecord::Migration
  def self.up
    create_table :dns_models do |t|
      t.string :name
      t.integer :ttl
      t.string :rdtype
      t.string :rdata

      t.timestamps
    end

    #initialise avec les valeurs de la table pas bien
    # Dns.all.each do |dns|
      # dnsm = DnsModel.new
      # dnsm.name = dns.name
      # dnsm.ttl = dns.ttl
      # dnsm.rdtype = dns.rdtype
      # dnsm.rdata = dns.rdata
      # dnsm.save
    # end
  end

  def self.down
    drop_table :dns_models
  end
end
