class FacebookList < ActiveRecord::Base
  attr_accessible :name, :photo_url

  belongs_to :user

  validates :user_id, presence: true
  validates :name, length: { maximum: 50 }

end
