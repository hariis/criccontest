class AddContestCurrentToContest < ActiveRecord::Migration
   def self.up
    add_column :contests, :contest_current, :boolean, :default => true

    add_index :contests, :contest_current
    end

   def self.down
     remove_column :contests, :contest_current
   end
end