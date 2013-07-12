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

  # facebook lists
  has_many :facebook_lists, dependent: :destroy

  # pages
  has_many :user_page_relationships, foreign_key: "user_id"
  has_many :pages, through: :user_page_relationships

  has_many :user_plan_relationships, foreign_key: "user_id", dependent: :destroy
  has_many :plans, through: :user_plan_relationships

  before_save { self.email.downcase! if !self.email.nil? }
  before_save :create_remember_token
  after_save :set_free_plan


  validates :name, presence: true, length: { maximum: 50 }

  VALID_EMAIL_REGEX = /\A\w+(\w|[.]|[-]|[+])+@[a-z]([a-z]|[-]|[.])+[.][a-z]+\z/i
  validates :email, format: { with: VALID_EMAIL_REGEX }, 
                    allow_blank: true, # allow_blank: true, allow_nil: false
                    uniqueness: { case_sensitive: false }


  # user admin n pages. This method is called from pages_create_or_update in pages_helper
  def rel_user_page!(this_page)
    self.user_page_relationships.find_or_create_by_page_id(this_page.id)
  end

  def token(provider)
    self.authentications.find_by_provider(provider).token    
  end

  def set_plan!(plan, expiration_date=nil)
    today = Time.now.strftime("%Y%m%d").to_i
    if !active_plans.empty?
      active_plans.each do |p|
         p.expirate!
      end
    end
    upr = self.user_plan_relationships.new
    upr.plan_id = plan.id
    upr.effective_date = today
    upr.expiration_date = expiration_date
    upr.save!
  end

  def active_plans
    user_plan_relationships.where("effective_date <= ? and (expiration_date is null or expiration_date > ?)", Time.now.strftime("%Y%m%d").to_i, Time.now.strftime("%Y%m%d").to_i)
  end

  def plan
    active_plans.first
  end

  private

    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end

    def set_free_plan
      if self.plan.nil?
        self.set_plan!(Plan.find_by_name(FREE_PLAN))
      end
    end

end
