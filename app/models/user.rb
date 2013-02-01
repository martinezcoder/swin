# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
  attr_accessible :email, :name
  has_many :authentications

  before_save { self.email.downcase! if !self.email.nil? }
  before_save :create_remember_token
  
  validates :name, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A\w+(\w|[.]|[-]|[+])+@[a-z]([a-z]|[-]|[.])+[.][a-z]+\z/i
  validates :email, format: { with: VALID_EMAIL_REGEX }, 
                    allow_blank: true,
                    uniqueness: { case_sensitive: false }

  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

end
