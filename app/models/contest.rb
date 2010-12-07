class Contest < ActiveRecord::Base
  has_many   :posts, :dependent => :destroy
  belongs_to :owner, :class_name => 'User', :foreign_key => :user_id
  
  has_many :teams, :dependent => :destroy
  has_many :matches, :dependent => :destroy

end
