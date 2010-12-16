class CreatePrizes < ActiveRecord::Migration
  def self.up
    create_table :prizes do |t|
      t.references :post
      t.references :user

      t.string :title
      t.integer :amount
      t.timestamps

    end
  end

  def self.down
    drop_table :prizes
  end
end
