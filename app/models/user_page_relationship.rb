class UserPageRelationship < ActiveRecord::Base
  attr_accessible :page_id

  belongs_to :user, class_name: "User"
  belongs_to :page, class_name: "Page"
  
  validates :user_id, presence: true
  validates :page_id, presence: true
  
end
