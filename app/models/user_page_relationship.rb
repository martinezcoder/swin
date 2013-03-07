# == Schema Information
#
# Table name: user_page_relationships
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  page_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  active     :boolean          default(FALSE)
#


class UserPageRelationship < ActiveRecord::Base
  attr_accessible :page_id, :active

  belongs_to :user, class_name: "User"
  belongs_to :page, class_name: "Page"
  
  validates :user_id, presence: true
  validates :page_id, presence: true
  
  def desactivate
    self.active = false
    self.save!
  end

  def activate
    other_active_page = User.find(self.user_id).active_page_rel #user_page_relationships.find_by_active(true)
    other_active_page.desactivate if !other_active_page.nil?
    self.active = true
    self.save!
  end

end
