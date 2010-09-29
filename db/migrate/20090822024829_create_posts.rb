class CreatePosts < ActiveRecord::Migration  
  def self.up
    create_table :posts , :force => true do |t|    
      t.references :user
      t.references :contest
      
      t.string :subject,      :null => false
      t.string :url
      t.string :unique_id,    :null => false
      t.boolean :public,      :default => false
      t.text :note
      t.text :description
      t.boolean :allow_others_to_invite, :default => true

      t.timestamps
    end
    add_index(:posts, :unique_id, :unique => true)
  end

  def self.down
    drop_table :posts
  end
end
