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

  attr_accessible :page_id, :name, :page_type 

  has_many :user_page_relationships, foreign_key: "page_id", dependent: :destroy
  has_many :users, through: :user_page_relationships
  
  # what pages I consider my competitors
  has_many :page_relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :competitors, through: :page_relationships #, source: :competitor

  # pages who considers me his competitor
  has_many :reverse_page_relationships, foreign_key: "competitor_id", class_name: "PageRelationship", dependent: :destroy
  has_many :followers, through: :reverse_page_relationships #, source: :follower

  has_many :list_page_relationships, foreign_key: "page_id", class_name: "ListPageRelationship", dependent: :destroy
  has_many :lists, through: :list_page_relationships

  has_many :page_streams
  has_many :page_data_days

  validates :page_id, presence: true

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

  def activate_user_page(user)
    user.user_page_relationships.find_by_page_id(self).activate
  end


end
