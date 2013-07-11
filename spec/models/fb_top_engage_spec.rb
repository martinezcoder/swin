# == Schema Information
#
# Table name: fb_top_engages
#
#  id                  :integer          not null, primary key
#  day                 :integer
#  page_id             :integer
#  page_fb_id          :string(255)
#  fan_count           :integer
#  variation           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  talking_about_count :integer
#

require 'spec_helper'

describe FbTopEngage do

  let(:fb_top_engage) { FactoryGirl.create(:fb_top_engage) }
  
  subject { fb_top_engage }
  
  it { should respond_to(:day) }
  it { should respond_to(:page_id) }
  it { should respond_to(:page_fb_id) }
  it { should respond_to(:fan_count) }
  it { should respond_to(:talking_about_count) }
  it { should respond_to(:variation) }

  describe "accessible attributes" do
    it "should not allow access to day" do
      expect do
        FbTopEngage.new(day: fb_top_engage.day)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow access to page_id" do
      expect do
        FbTopEngage.new(page_id: fb_top_engage.page_id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow access to page_fb_id" do
      expect do
        FbTopEngage.new(page_fb_id: fb_top_engage.page_fb_id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    it "should not allow access to fan_count" do
      expect do
        FbTopEngage.new(fan_count: fb_top_engage.fan_count)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
    it "should not allow access to talking_about_count" do
      expect do
        FbTopEngage.new(talking_about_count: fb_top_engage.talking_about_count)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    

    it "should not allow access to variation" do
      expect do
        FbTopEngage.new(variation: fb_top_engage.variation)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "valid attributes" do
    describe "when day is not present" do
      before { fb_top_engage.day = "" }
      it { should_not be_valid }
    end
    describe "when page_id is not present" do
      before { fb_top_engage.page_id = "" }
      it { should_not be_valid }
    end
    describe "when page_fb_id is not present" do
      before { fb_top_engage.page_fb_id = "" }
      it { should_not be_valid }
    end
    describe "when fan_count is not present" do
      before { fb_top_engage.fan_count = "" }
      it { should_not be_valid }
    end
    describe "when talking_about_count is not present" do
      before { fb_top_engage.talking_about_count = "" }
      it { should_not be_valid }
    end
    describe "when variation is not present" do
      before { fb_top_engage.variation = "" }
      it { should_not be_valid }
    end
  end

end
