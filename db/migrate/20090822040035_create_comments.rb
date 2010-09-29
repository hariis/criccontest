class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments , :force => true do |t|
      t.references :user
      t.references :post
      t.text :body,          :null => false
      t.integer :parent_id
      t.boolean :sticky, :default => 0

      t.timestamps
    end

    add_index :comments, :parent_id
  end

  def self.down
    drop_table :comments
  end
end
