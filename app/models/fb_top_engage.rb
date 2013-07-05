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
