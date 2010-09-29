class Entry < ActiveRecord::Base
  belongs_to :category
  has_many :predictions, :dependent => :destroy
  has_many :results, :dependent => :destroy
end
