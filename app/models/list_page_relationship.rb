class ListPageRelationship < ActiveRecord::Base
  attr_accessible :page_id
  
  belongs_to :list, class_name: "FacebookList"
  belongs_to :page
  
  validates :page_id, presence: true
  validates :list_id, presence: true
end
