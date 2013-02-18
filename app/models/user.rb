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
  attr_accessible :email, :name, :terms_of_service 
  validates_acceptance_of :terms_of_service, :on => :create, :accept => '1', :allow_nil => false
  attr_accessor :terms_of_service

  # authentications
  has_many :authentications, dependent: :destroy

  # pages
  has_many :user_page_relationships, foreign_key: "user_id"
  has_many :pages, through: :user_page_relationships


  before_save { self.email.downcase! if !self.email.nil? }
  before_save :create_remember_token


  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A\w+(\w|[.]|[-]|[+])+@[a-z]([a-z]|[-]|[.])+[.][a-z]+\z/i
  validates :email, format: { with: VALID_EMAIL_REGEX }, 
                    allow_blank: true, # allow_blank: true, allow_nil: false
                    uniqueness: { case_sensitive: false }


  def set_page!(this_page)
    self.user_page_relationships.find_or_create_by_page_id(this_page.id)
  end
  
  
  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

end
