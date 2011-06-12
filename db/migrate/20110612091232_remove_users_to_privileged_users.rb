class RemoveUsersToPrivilegedUsers < ActiveRecord::Migration
  def self.up
    remove_column :privileged_users, :users
  end

  def self.down
    add_column :privileged_users, :users, :integer
  end
end
