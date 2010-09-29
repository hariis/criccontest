class Spectator < ActiveRecord::Base
  belongs_to :engagement
  belongs_to :match
  has_many :predicitions,  :dependent => :destroy
end
