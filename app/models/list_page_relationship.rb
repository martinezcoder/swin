class ListPageRelationship < ActiveRecord::Base
  attr_accessible :page_id
  
  belongs_to :facebook_list
  
end
