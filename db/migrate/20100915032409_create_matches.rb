class CreateMatches < ActiveRecord::Migration
  def self.up
    create_table :matches do |t|

      t.references :contest
      t.references :user
      t.references :category

      t.integer :firstteam
      t.integer :secondteam
      t.date :date
      t.text :description
      t.string :venue
      t.time :starttime
      t.string :unique_id

      t.timestamps

    end
  end

  def self.down
    drop_table :matches
  end
end
