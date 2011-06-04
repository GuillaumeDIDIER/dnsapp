class CreateSerialModels < ActiveRecord::Migration
  def self.up
    create_table :serial_models do |t|
      t.string :nom
      t.integer :valeur

      t.timestamps
    end
  end

  def self.down
    drop_table :serial_models
  end
end
