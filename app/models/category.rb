class Category < ActiveRecord::Base
  has_many :matches
  has_many :entries
end
