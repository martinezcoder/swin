# encoding: UTF-8
# == Schema Information
#
# Table name: users
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  email          :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  remember_token :string(255)
#

class User < ActiveRecord::Base
  attr_accessor :policy_checked
  attr_accessible :email, :name, :policy_checked

  has_many :authentications, dependent: :destroy

  before_save { self.email.downcase! if !self.email.nil? }
  before_save :create_remember_token


  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A\w+(\w|[.]|[-]|[+])+@[a-z]([a-z]|[-]|[.])+[.][a-z]+\z/i
  validates :email, format: { with: VALID_EMAIL_REGEX }, 
                    allow_blank: true, # allow_blank: true, allow_nil: false
                    uniqueness: { case_sensitive: false }

#  validates :policy_checked, inclusion: { in: %w(1), message: "Acepte las condiciones de uso y política de privacidad" }

  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

end
