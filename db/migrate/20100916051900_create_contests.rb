class CreateContests < ActiveRecord::Migration
  def self.up
    create_table :contests do |t|
      t.string :name,          :null => false
      t.text :description
      t.string :url
      t.references :user

      t.timestamps

    end
  end

  def self.down
    drop_table :contests
  end
end
