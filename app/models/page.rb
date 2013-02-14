class Page < ActiveRecord::Base
include PagesHelper

  attr_protected  :page_id, :name, :page_url, :pic_square, :page_type, :username
  
  # what pages I consider my competitors
  has_many :page_relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :competitors, through: :page_relationships #, source: :competitor

  # pages who considers me his competitor
  has_many :reverse_page_relationships, foreign_key: "competitor_id", class_name: "PageRelationship", dependent: :destroy
  has_many :followers, through: :reverse_page_relationships #, source: :follower

  validates :page_id, presence: true

  def following?(other_page)
    page_relationships.find_by_competitor_id(other_page.id)
  end

  def follow!(other_page)
#    page_list = []
#    page_list[0] = other_page.instance_values["attributes"]    
#    pages_create_or_update(page_list)
    page_create_or_update(other_page)
    page_relationships.create!(competitor_id: other_page.id)
  end

  def unfollow!(other_page)
    page_relationships.find_by_competitor_id(other_page.id).destroy
  end

end
