class AddUnauthorizedNamesToPrivilegedUsers < ActiveRecord::Migration
  def self.up
    add_column :privileged_users, :unauthorized_names, :int
  end

  def self.down
    remove_column :privileged_users, :unauthorized_names
  end
end
