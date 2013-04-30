class FacebookList < ActiveRecord::Base
  attr_accessible :name, :photo_url

  belongs_to :user
  
  has_many :list_page_relationships, foreign_key: "list_id", dependent: :destroy

  validates :user_id, presence: true
  validates :name, length: { maximum: 50 }

end
