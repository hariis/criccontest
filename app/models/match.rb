class Match < ActiveRecord::Base
  belongs_to :category
  belongs_to :contest
  belongs_to :owner, :class_name => 'User', :foreign_key => :user_id
  has_many :spectators, :dependent => :destroy
  has_many :results, :dependent => :destroy
  
  #has_many :engagements, :through => :spectators
  
  def get_url_for(eng, action)
    if eng.nil?
        if action == 'show' || action == 'result'
          #DOMAIN + "spectators/" + action + "?mid=#{self.unique_id}&uid=#{user.unique_id}"
          DOMAIN + "spectators/" + action + "?mid=#{self.unique_id}"
        elsif action == 'predicitions'
          DOMAIN + "predicitions/show" + "?mid=#{self.unique_id}"
        end
    else
        if action == 'show' || action == 'result'
          #DOMAIN + "spectators/" + action + "?mid=#{self.unique_id}&uid=#{user.unique_id}"
          DOMAIN + "spectators/" + action + "?mid=#{self.unique_id}&eid=#{eng.unique_id}"
        elsif action == 'predicitions'
          DOMAIN + "predicitions/show" + "?mid=#{self.unique_id}&eid=#{eng.unique_id}"
        end
    end 
  end

  def get_readonly_url(action)
    inviter = User.get_open_contest_inviter
    if action == 'show'
        DOMAIN + "spectators/show" + "?mid=#{self.unique_id}&iid=#{inviter.unique_id}"
    elsif action == 'predicitions'
        DOMAIN + "predicitions/show" + "?mid=#{self.unique_id}&iid=#{inviter.unique_id}"
    end
  end
  
  def check_if_match_started
    Time.now.utc > date_time
  end
  
  def display_match_start_time
    Time.zone = self.time_zone
    start_date_time = self.date_time.inspect  #Check if the current time at the venue is greater than match start time.
    Time.zone = 'UTC'
    return start_date_time
  end
  
  def set_match_predicition_for_admin
    DOMAIN + "predicitions/show" + "?mid=#{self.unique_id}"
  end
  
  def create_all_entries_for_the_match(contest)
    contest.posts.each do |post|
      #check and create spectator
      post.engagements.each do |engagement|
        create_spectator_and_send_email(self, engagement)
      end
    end
    create_result_table(self)
  end

  def create_spectator_and_send_email(match, engagement)
    spectator_exists = Spectator.find(:first, :conditions => ['match_id = ? && engagement_id = ?', match.id, engagement.id])
    post = Post.find_by_id(engagement.post_id)
    user = User.find_by_id(engagement.user_id)
    
    unless spectator_exists
      spectator = Spectator.new
      spectator.engagement_id = engagement.id
      spectator.match_id = match.id
      spectator.totalscore = 0
      spectator.save

      #check and create predicition
      category = Category.find(match.category_id)
      category.entries.each do |entry|        
          predicition_exists = Predicition.find(:first, :conditions => ['spectator_id = ? && entry_id = ?', spectator.id, entry.id])
          unless predicition_exists
              predicition = Predicition.new
              predicition.spectator_id = spectator.id
              predicition.entry_id = entry.id
              predicition.user_predicition = -1
              predicition.score = 0
              predicition.save
          end
      end

      #send email notification that match is added and available for predicition
      match_details = get_teamname(match.firstteam) + " vs " + get_teamname(match.secondteam)
      #TODO: Add it later after handling name_request for mid and eid
      #Notifier.deliver_send_match_invitations(post, match, user, engagement, match_details)
    end
  end
  
  def create_result_table(match)
    category = Category.find(match.category_id)
    category.entries.each do |entry|        
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
  
  def self.get_next_scheduled_match(contest)
    #TODO Fix it. sql query not complete
    #contest.matches.each do |match|
    #  if !match.check_if_match_started
    #    return match
    #  end
    #end
    #return contest.matches.find(:first)
    match = contest.matches.find(:first, :conditions => ["date_time > ?", Time.now] )    
    if match.nil?
        match = contest.matches.find(:last)
    end
    return match
  end
  
  private  
  def self.generate_unique_id
    ActiveSupport::SecureRandom.hex(20)
  end
  
  def get_teamname(teamid)
    Team.find_by_id(teamid).teamname
  end
end