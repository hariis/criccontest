class CreateEngagements < ActiveRecord::Migration  
  def self.up
    create_table :engagements, :force => true do |t|
      t.references :user
      t.references :post
      t.integer :invited_by,    :null => false
      t.datetime :invited_when, :null => false
      t.string  :invited_via, :default => "email", :null => false
      t.boolean :notify_me, :default => true
      t.boolean :joined, :default => false
      t.boolean :shared, :default => false
      t.datetime :last_viewed_at
      t.string :unique_id
      t.integer :totalscore
    
      t.timestamps
    end
      add_index   :engagements, :invited_by
  end

  def self.down
    drop_table :engagements
  end
end
