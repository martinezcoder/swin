# == Schema Information
#
# Table name: fb_top_engages
#
#  id                  :integer          not null, primary key
#  day                 :integer
#  page_id             :integer
#  page_fb_id          :string(255)
#  fan_count           :integer
#  variation           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  talking_about_count :integer
#

class FbTopEngage < ActiveRecord::Base
  attr_accessor :engagement
  
  belongs_to :page
  
  validates :day,                 presence: true
  validates :page_id,             presence: true
  validates :page_fb_id,          presence: true
  validates :fan_count,           presence: true
  validates :talking_about_count, presence: true
  validates :variation,           presence: true

end
