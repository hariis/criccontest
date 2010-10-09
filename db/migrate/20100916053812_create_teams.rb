class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|

      t.references :contest
      t.string :teamname
      t.timestamps

    end
  end

  def self.down
    drop_table :teams
  end
end
