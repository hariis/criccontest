class CreateResults < ActiveRecord::Migration
  def self.up
    create_table :results do |t|

      t.references :match
      t.references :entry
      t.integer :result, :default => -1
      
      t.timestamps
    end
  end

  def self.down
    drop_table :results
  end
end
