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

require 'spec_helper'

describe PageRelationship do
  pending "add some examples to (or delete) #{__FILE__}"
end
