# encoding: UTF-8
# == Schema Information
#
# Table name: authentications
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  provider   :string(255)
#  uid        :string(255)
#  token      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#



class Authentication < ActiveRecord::Base

  belongs_to :user

  validates :user_id, presence: true
  validates :provider, presence: true, inclusion: { in: %w(facebook twitter youtube), message: "%{value} no es proveedor válido" }
  validates :uid, presence: true, :length => { :maximum => 40 }, :numericality => { :only_integer => true }

  validates_uniqueness_of :user_id, :scope => :provider

end
