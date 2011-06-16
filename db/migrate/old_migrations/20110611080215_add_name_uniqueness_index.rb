class AddNameUniquenessIndex < ActiveRecord::Migration
  def self.up
    add_index :privileged_users, :name, :unique => true
  end

  def self.down
    remove_index :privileged_users, :name
  end
end
