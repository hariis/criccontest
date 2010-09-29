class Engagement < ActiveRecord::Base
  belongs_to :invitee, :class_name => 'User', :foreign_key => :user_id
  belongs_to :post
  has_many :spectators, :dependent => :destroy
  has_many :matches, :through => :spectators 

  def self.get_followers(from_config)

     begin
         get_followers_safe(from_config)

     rescue Exception => e
        logger.info e
        raise $! # rethrow     
     end
  end
  
  def create_spectator_and_send_email
    post = Post.find_by_id(self.post_id)
    contest = Contest.find_by_id(post.contest_id) if post
    unless contest.nil?
      contest.matches.each do |match|
        #TODO: do it only for the future matches. Ignore the past matches which cannot be predicted anymore
        match.create_spectator_and_send_email(match, self)
      end
    end
  end
 
  private
  
  def self.generate_unique_id
    ActiveSupport::SecureRandom.hex(20)
  end
  
  def self.get_followers_safe(from_config)
     httpauth = Twitter::HTTPAuth.new(from_config[:twitid], from_config[:password])
          1.upto(3).each do
              base = Twitter::Base.new(httpauth)
               #check if we got the right response object
               return base.followers if base && base.followers.first.screen_name != nil
         end
         raise
  end
end
