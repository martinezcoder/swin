class Page < ActiveRecord::Base
  attr_accessible :page_id, :name, :page_url, :pic_square, :page_type, :username
  
  validates :page_id, presence: true
end
