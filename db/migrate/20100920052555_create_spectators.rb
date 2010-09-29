class CreateSpectators < ActiveRecord::Migration
  def self.up
    create_table :spectators do |t|

      t.references :engagement
      t.references :match
      t.integer :totalscore

      t.timestamps

    end
  end

  def self.down
    drop_table :spectators
  end
end
