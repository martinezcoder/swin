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

require 'spec_helper'

describe PageStream do
  pending "add some examples to (or delete) #{__FILE__}"
end
