# == Schema Information
#
# Table name: pages
#
#  id                  :integer          not null, primary key
#  page_id             :string(255)
#  name                :string(255)
#  page_type           :string(255)
#  username            :string(255)
#  page_url            :string(255)
#  pic_square          :string(255)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  fan_count           :integer
#  talking_about_count :integer
#

require 'spec_helper'

describe Page do

  let(:user) { FactoryGirl.create(:user) }
  before { 
          @page = user.pages.build(
                    page_id: "349679691794392",
                    name: "SocialWin",
                    page_url: "http://www.facebook.com/pages/SocialWin/349679691794392",
                    pic_square: "http://profile.ak.fbcdn.net/hprofile-ak-snc6/276654_349679691794392_1240268105_q.jpg",
                    page_type: "CONSULTING/BUSINESS SERVICES",
                    username: "socialwin"
                   ) 
         }
  
  subject { @page }

  it { should respond_to(:page_id) }
  it { should respond_to(:name) }
  it { should respond_to(:username) }
  it { should respond_to(:page_type) }    
  it { should respond_to(:page_url) }
  it { should respond_to(:pic_square) }
  it { should respond_to(:pic_big) }

  it { should respond_to(:list_page_relationships) }
  it { should respond_to(:facebook_lists) }

  
  it { should be_valid }

  describe "accessible attributes" do
    it "should not allow access to user_id" do
      expect do
        UserPageRelationship.new(user_id: user.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end

  describe "when page_id is not present" do
    before { @page.page_id = nil }
    it { should_not be_valid }
  end

end
