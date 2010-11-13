class AddMatchResult < ActiveRecord::Migration
  def self.up
    add_column :matches, :match_result, :string, :default => "Results not yet updated"
  end

  def self.down
    remove_column :matches, :match_result
  end
end