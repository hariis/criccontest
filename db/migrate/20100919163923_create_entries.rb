class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|

      t.references :category
      t.string :name
      t.integer :posweight
      t.integer :negweight


      t.timestamps

    end
  end

  def self.down
    drop_table :entries
  end
end
