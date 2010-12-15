class AddTotalScoreToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :total_score, :integer
  end

  def self.down
    remove_column :users, :total_score
  end
end
