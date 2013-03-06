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

require 'spec_helper'

describe PageDataDay do
  pending "add some examples to (or delete) #{__FILE__}"
end
