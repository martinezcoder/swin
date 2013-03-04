# == Schema Information
#
# Table name: pages
#
#  id                  :integer          not null, primary key
#  page_id             :string(255)
#  name                :string(255)
#  page_type           :string(255)
#  username            :string(255)
#  page_url            :string(255)
#  pic_square          :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  fan_count           :integer
#  talking_about_count :integer
#

class Page < ActiveRecord::Base
  include PagesHelper
  
  has_many :user_page_relationships, foreign_key: "page_id"
  has_many :users, through: :user_page_relationships
  
  # what pages I consider my competitors
  has_many :page_relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :competitors, through: :page_relationships #, source: :competitor

  # pages who considers me his competitor
  has_many :reverse_page_relationships, foreign_key: "competitor_id", class_name: "PageRelationship", dependent: :destroy
  has_many :followers, through: :reverse_page_relationships #, source: :follower

  has_many :page_streams
  has_one :page_data_day

  validates :page_id, presence: true

  default_scope order: 'pages.created_at DESC'

  def following?(other_page_id)
    self.competitors.find_by_page_id(other_page_id.to_s)
  end

  def follow!(other_page)
    begin
#    page_list = []
#    page_list[0] = other_page.instance_values["attributes"]    
#    pages_create_or_update(page_list)
      page_relationships.create!(competitor_id: other_page.id)
    rescue
      nil
    end
  end

  def unfollow!(other_page)
    page_relationships.find_by_competitor_id(other_page.id).destroy
  end


end
