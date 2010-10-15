class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :engagements, :post_id
    add_index :comments, :user_id
    add_index :comments, :sticky
    add_index :groups, :name
    add_index :groups, :user_id
    add_index :memberships, :group_id
    add_index :memberships, :user_id
    add_index :shared_posts, :post_id
    add_index :shared_posts, :user_id
    add_index :categories, :name
    add_index :entries, :category_id
    add_index :matches, :unique_id
    add_index :predicitions, :entry_id
    add_index :predicitions, :spectator_id
    add_index :spectators, :engagement_id
    add_index :spectators, :match_id
    add_index :predict_total_scores, :label_text
    add_index :teams, :contest_id
  end

  def self.down
    remove_index :users, :unique_id, :unique => true
    remove_index :posts, :unique_id, :unique => true
    remove_index :engagements, :post_id
    remove_index :comments, :user_id
    remove_index :comments, :sticky
    remove_index :groups, :name
    remove_index :groups, :user_id
    remove_index :memberships, :group_id
    remove_index :memberships, :user_id
    remove_index :shared_posts, :post_id
    remove_index :shared_posts, :user_id
    remove_index :categories, :name
    remove_index :entries, :category_id
    remove_index :matches, :unique_id
    remove_index :predicitions, :entry_id
    remove_index :predicitions, :spectator_id
    remove_index :spectators, :engagement_id
    remove_index :spectators, :match_id
    remove_index :predict_total_scores, :label_text
    remove_index :teams, :contest_id
  end
end
