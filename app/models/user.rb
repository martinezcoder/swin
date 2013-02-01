class User < ActiveRecord::Base
  attr_accessible :email, :name
  has_many :authentications

  before_save { self.email.downcase! }
  
  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A\w+(\w|[.]|[-]|[+])+@[a-z]([a-z]|[-]|[.])+[.][a-z]+\z/i
  validates :email, presence:true, 
                    format: { with: VALID_EMAIL_REGEX }, 
                    allow_blank: false,
                    uniqueness: { case_sensitive: false }

end
