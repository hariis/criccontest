class CreatePredicitions < ActiveRecord::Migration
  def self.up
    create_table :predicitions do |t|
      
      t.references :entry
      t.references :spectator
      
      t.integer :user_predicition, :default => -1
      t.integer :score

      t.timestamps

    end
  end

  def self.down
    drop_table :predicitions
  end
end
