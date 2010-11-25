class Predicition < ActiveRecord::Base
  belongs_to :spectator
  belongs_to :entry
  
  #WIN_MARGIN_WICKET = { "<2" => "1", "3-4" => "2", "5-6" => "3", "7-8" => "4", "9-10" => "5" }
  #WIN_MARGIN_SCORE = { "<25" => "1", "26-50" => "2", "51-75" => "3", "76-100" => "4", ">100" => "5" }
  
  WIN_MARGIN_WICKET = ["<2", "3-4", "5-6", "7-8", "9-10" ]
  WIN_MARGIN_SCORE = ["<25", "26-50", "51-75", "76-100", ">100" ]
  
  PREDICT_TOTAL_SCORE = { "<200" => "1", "201-225" => "2", "226-250" => "3", "251-275" => "4", "276-300" => "5", ">300" => "6" }
  
  def self.predicition_notification(post_id, match, user_name, predicition_details)
    post = Post.find(post_id)
    post.participants_to_notify.each do |participant|
      engagement = Engagement.find_by_post_id_and_user_id(post_id, participant.id)
      Notifier.deliver_predicition_notification(post, engagement, match, user_name, predicition_details, participant)
    end
  end
       
end
