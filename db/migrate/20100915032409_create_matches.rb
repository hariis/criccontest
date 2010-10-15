class CreateMatches < ActiveRecord::Migration
  def self.up
    create_table :matches do |t|

      t.references :contest
      t.references :user
      t.references :category

      t.integer :firstteam
      t.integer :secondteam
      t.datetime :date_time
      t.text :description
      t.string :venue
      t.string :unique_id
      t.string :time_zone

      t.timestamps

    end
  end

  def self.down
    drop_table :matches
  end
end
