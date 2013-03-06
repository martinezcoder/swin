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

require 'spec_helper'

describe UserPageRelationship do
  pending "add some examples to (or delete) #{__FILE__}"
end
