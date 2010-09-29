class Result < ActiveRecord::Base
  belongs_to :match
  belongs_to :entry
end
