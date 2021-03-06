class Predicition < ActiveRecord::Base
  belongs_to :spectator
  belongs_to :entry
  
  #WIN_MARGIN_WICKET = { "<2" => "1", "3-4" => "2", "5-6" => "3", "7-8" => "4", "9-10" => "5" }
  #WIN_MARGIN_SCORE = { "<25" => "1", "26-50" => "2", "51-75" => "3", "76-100" => "4", ">100" => "5" }
  
  WIN_MARGIN_WICKET = ["<2", "3-4", "5-6", "7-8", "9-10"]
  WIN_MARGIN_SCORE = ["<25", "26-50", "51-75", "76-100", ">100"]
  
  WIN_MARGIN_SCORE_TWENTY20 = ["<20", "21-40", "41-60", "61-80", ">80"]
  PREDICT_TOTAL_SCORE_TWENTY20 = ["<100", "101-120", "121-140", "141-160", "161-180", "181-200", ">200"]

  CATEGORY = {"One day match" => "1"}  
  PREDICT_TOTAL_SCORE = { "<200" => "1", "201-225" => "2", "226-250" => "3", "251-275" => "4", "276-300" => "5", ">300" => "6" }
  ENTRIES = { "winner" => "1", "toss" => "2", "ts_firstteam" => "3", "ts_secondteam" => "4", "win_margin_wicket" => "5", "win_margin_score" => "6" }
  
  def self.predicition_notification(post_id, match, user_name, predicition_details)
    post = Post.find(post_id)
    post.participants_to_notify.each do |participant|
      engagement = Engagement.find_by_post_id_and_user_id(post_id, participant.id)
      Notifier.deliver_predicition_notification(post, engagement, match, user_name, predicition_details, participant)
    end
  end
       
end
