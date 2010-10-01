class CreatePredictTotalScores < ActiveRecord::Migration
  def self.up
    create_table :predict_total_scores do |t|

      t.string :label_text
      t.timestamps

    end
  end

  def self.down
    drop_table :predict_total_scores
  end
end
