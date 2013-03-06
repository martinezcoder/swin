# == Schema Information
#
# Table name: page_relationships
#
#  id            :integer          not null, primary key
#  follower_id   :integer
#  competitor_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#



class PageRelationship < ActiveRecord::Base
  attr_accessible :competitor_id
  
  belongs_to :follower, class_name: "Page"
  belongs_to :competitor, class_name: "Page"
  
  validates :follower_id, presence: true
  validates :competitor_id, presence: true
end
