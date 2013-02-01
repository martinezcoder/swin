class Authentication < ActiveRecord::Base
  attr_accessible :provider, :token, :uid
  
  belongs_to :user
  
  validates :user_id, presence: true
end
