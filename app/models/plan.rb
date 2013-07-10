# == Schema Information
#
# Table name: plans
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  num_competitors :integer
#  num_lists       :integer
#  price           :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Plan < ActiveRecord::Base
#  attr_accessible :name, :num_competitors, :num_lists, :price
end
