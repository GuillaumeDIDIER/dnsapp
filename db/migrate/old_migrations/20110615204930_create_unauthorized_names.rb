class CreateUnauthorizedNames < ActiveRecord::Migration
  def self.up
    create_table :unauthorized_names do |t|
      t.string :name
      t.string :comment

      t.timestamps
    end

    add_index :unauthorized_names, :name, :unique => true
  end

  def self.down
    drop_table :unauthorized_names
  end
end
