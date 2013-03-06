# == Schema Information
#
# Table name: page_streams
#
#  id             :integer          not null, primary key
#  page_id        :integer
#  post_id        :string(255)
#  permalink      :string(255)
#  media_type     :string(255)
#  actor_id       :string(255)
#  target_id      :string(255)
#  likes_count    :integer
#  comments_count :integer
#  share_count    :integer
#  created_time   :integer
#  day            :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#


class PageStream < ActiveRecord::Base
  belongs_to :page
  validates :page_id, presence: true
end


