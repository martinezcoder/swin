# == Schema Information
#
# Table name: pages
#
#  id                  :integer          not null, primary key
#  page_id             :string(255)
#  name                :string(255)
#  page_type           :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  fan_count           :integer
#  talking_about_count :integer
#



class Page < ActiveRecord::Base
  include PagesHelper

  attr_accessor :pic_square
  attr_accessible :page_id, :name, :page_type 

  has_many :user_page_relationships, foreign_key: "page_id", dependent: :destroy
  has_many :users, through: :user_page_relationships

  has_many :list_page_relationships, foreign_key: "page_id", class_name: "ListPageRelationship", dependent: :destroy
  has_many :lists, through: :list_page_relationships

  has_many :page_streams,   dependent: :destroy
  has_many :page_data_days, dependent: :destroy
  has_many :fb_top_engage,  dependent: :destroy

  validates :page_id, presence: true

end
