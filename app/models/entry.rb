class Entry < ActiveRecord::Base
  belongs_to :category
  has_many :predictions, :dependent => :destroy
  has_many :results, :dependent => :destroy
  
  def create_spectator_and_predictions_for_new_rules
    contests = Contest.find(:all)
    contests.each do |contest|
        contest.posts.each do |post|
          post.engagements.each do |engagement|
            #check and create spectator
            create_spectator_and_predictions(self, engagement, contest)
          end
        end
        #create_result_table(entry)
    end
  end
  
  def create_spectator_and_predictions(entry, engagement, contest)
      matches = contest.matches.find_all_by_category_id(entry.category_id)
      matches.each do |match|
          spectator_exists = Spectator.find(:first, :conditions => ['match_id = ? && engagement_id = ?', match.id, engagement.id])
          post = Post.find_by_id(engagement.post_id)
          user = User.find_by_id(engagement.user_id)

          if spectator_exists
            spectator = spectator_exists
          else
            spectator = Spectator.new
            spectator.engagement_id = engagement.id
            spectator.match_id = match.id
            spectator.totalscore = 0
            spectator.save
          end

          #check and create predicition
          predicition_exists = Predicition.find(:first, :conditions => ['spectator_id = ? && entry_id = ?', spectator.id, entry.id])
          unless predicition_exists
              predicition = Predicition.new
              predicition.spectator_id = spectator.id
              predicition.entry_id = entry.id
              predicition.user_predicition = -1
              predicition.score = 0
              predicition.save
          end
          
          result_exists = Result.find(:first, :conditions => ['match_id = ? && entry_id = ?', match.id, entry.id])
          unless result_exists
              result = Result.new
              result.match_id = match.id
              result.entry_id = entry.id
              result.result = -1
              result.save
          end
      end
  end
  
end
