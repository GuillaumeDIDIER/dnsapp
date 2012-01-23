class CreateZones < ActiveRecord::Migration
  def self.up
    create_table :zones do |t|
      t.string :zone
      t.string :name

      t.timestamps
    end

    add_index :zones, :zone, :unique => true
  end

  def self.down
    drop_table :zones
  end
end
