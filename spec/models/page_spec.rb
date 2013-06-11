# == Schema Information
#
# Table name: pages
#
#  id                  :integer          not null, primary key
#  page_id             :string(255)
#  name                :string(255)
#  page_type           :string(255)
#  username            :string(255)
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
                    page_type: "CONSULTING/BUSINESS SERVICES"
                   ) 
         }
  
  subject { @page }

  it { should respond_to(:page_id) }
  it { should respond_to(:name) }
  it { should respond_to(:page_type) } 

  it { should respond_to(:list_page_relationships) }
  it { should respond_to(:lists) }

  
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

  describe "when page is in a list" do
    let(:user) { FactoryGirl.create(:user) }
    let!(:face_list) do 
      FactoryGirl.create(:facebook_list, user: user, name: "first list", created_at: 1.day.ago)
    end
    before {  
      @page.save!
      face_list.add!(@page)
    }
    
    its(:lists) { should include(face_list) }
    
  end 
  
end
