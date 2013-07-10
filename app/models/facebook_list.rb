# == Schema Information
#
# Table name: facebook_lists
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  name       :string(255)
#  photo_url  :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  page_id    :integer
#

class FacebookList < ActiveRecord::Base
  attr_accessible :name, :page_id, :photo_url

  belongs_to :user
  
  has_many :list_page_relationships, foreign_key: "list_id", dependent: :destroy
  has_many :pages, through: :list_page_relationships

  validates :user_id, presence: true
  validates :name, length: { maximum: 50 }
#  validates :page_id, presence: true

  def set_lider_page(page)
    self.page_id = page.id
    save
  end
  
  def added?(page)
    list_page_relationships.find_by_page_id(page.id) 
  end
  
  def add!(page)
    list_page_relationships.create!(page_id: page.id)
  end

  def remove!(page)
    list_page_relationships.find_by_page_id(page.id).destroy
  end

end
