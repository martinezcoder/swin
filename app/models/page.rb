# == Schema Information
#
# Table name: pages
#
#  id                  :integer          not null, primary key
#  page_id             :string(255)
#  name                :string(255)
#  page_type           :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  fan_count           :integer
#  talking_about_count :integer
#



class Page < ActiveRecord::Base
  include PagesHelper

  attr_accessor :pic_square
  attr_accessible :page_id, :name, :page_type 

  has_many :user_page_relationships, foreign_key: "page_id", dependent: :destroy
  has_many :users, through: :user_page_relationships

  has_many :list_page_relationships, foreign_key: "page_id", class_name: "ListPageRelationship", dependent: :destroy
  has_many :lists, through: :list_page_relationships

  has_many :page_streams
  has_many :page_data_days

  validates :page_id, presence: true

  def picture(big=false)
    ret = "https://graph.facebook.com/" + page_id.to_s + "/picture"
    if big
      ret += "?type=large"
    end
    return self.pic_square || ret
  end

  def url
    "https://www.facebook.com/" + page_id.to_s
  end


end
