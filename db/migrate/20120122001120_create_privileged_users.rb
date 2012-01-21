class CreatePrivilegedUsers < ActiveRecord::Migration
  def self.up
    create_table :privileged_users do |t|
      t.string  :name
      t.string  :encrypted_password
      t.string  :salt
      t.boolean :admin
      t.integer :dns
      t.integer :alias
      t.integer :unauthorized_names

      t.timestamps
    end

    add_index :privileged_users, :name, :unique => true
  end

  def self.down
    drop_table :privileged_users
  end
end
