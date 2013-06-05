# == Schema Information
#
# Table name: page_data_days
#
#  id                 :integer          not null, primary key
#  page_id            :integer
#  likes              :integer
#  prosumers          :integer
#  comments           :integer
#  shared             :integer
#  total_likes_stream :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  day                :integer
#  posts              :integer
#

class PageDataDay < ActiveRecord::Base
  belongs_to :page
  validates :page_id, presence: true
  
  default_scope order: 'page_data_days.day ASC'
end

