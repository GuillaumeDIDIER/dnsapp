class CreateDnsModels < ActiveRecord::Migration
  def self.up
    create_table :dns_models do |t|
      t.string :name
      t.integer :ttl
      t.string :rdtype
      t.string :rdata

      t.timestamps
    end
  end

  def self.down
    drop_table :dns_models
  end
end
