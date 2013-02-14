class PageRelationship < ActiveRecord::Base
  attr_accessible :competitor_id
  
  belongs_to :follower, class_name: "Page"
  belongs_to :competitor, class_name: "Page"
  
  validates :follower_id, presence: true
  validates :competitor_id, presence: true
end
