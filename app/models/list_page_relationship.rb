# == Schema Information
#
# Table name: list_page_relationships
#
#  id         :integer          not null, primary key
#  list_id    :integer
#  page_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ListPageRelationship < ActiveRecord::Base
  attr_accessible :page_id
  
  belongs_to :list, class_name: "FacebookList"
  belongs_to :page
  
  validates :page_id, presence: true
  validates :list_id, presence: true
end
