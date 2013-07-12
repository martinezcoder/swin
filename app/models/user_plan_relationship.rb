# == Schema Information
#
# Table name: user_plan_relationships
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  plan_id         :integer
#  effective_date  :integer
#  expiration_date :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class UserPlanRelationship < ActiveRecord::Base
#  attr_accessible :effective_date, :expiration_date, :plan_id, :user_id
#  attr_accessible :user_id

  belongs_to :user 
  belongs_to :plan

  validates :user_id, presence: true
  validates :plan_id, presence: true
  validates :effective_date, presence: true
  validates :expiration_date, presence: true
  
  before_save :validate_dates?

private

  def validate_dates?
    (self.expiration_date > self.effective_date) 
  end  

end
