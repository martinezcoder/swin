# == Schema Information
#
# Table name: user_plan_relationships
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  plan_id         :integer
#  effective_date  :integer
#  expiration_date :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe UserPlanRelationship do

  let(:user) { FactoryGirl.create(:user) }
  let(:plan) { FactoryGirl.create(:plan) }


  before do
    @user_plan = user.user_plan_relationships.new
    @user_plan.plan_id = plan.id
    @user_plan.effective_date = 20130101
    @user_plan.expiration_date = 20140101
  end

  subject { @user_plan }
  
  it { should be_valid }

  describe "accessible attributes" do
    it "should not allow access to plan_id" do
      expect do
        UserPlanRelationship.new(plan_id: plan.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end

  describe "plans methods" do
      it { should respond_to(:user_id) }
      it { should respond_to(:plan_id) }
      its(:user) { should == user }
      its(:plan) { should == plan }
  end

  describe "when plan_id is not present" do
    before { @user_plan.plan_id = nil }
    it { should_not be_valid }
  end

  describe "when user_id is not present" do
    before { @user_plan.user_id = nil }
    it { should_not be_valid }
  end

  describe "when effective_date is not present" do
    before { @user_plan.effective_date = nil }
    it { should_not be_valid }
  end

  describe "when expiration_date is not present" do
    before { @user_plan.expiration_date = nil }
    it { should_not be_valid }
  end

  describe "when expiration_date is newwe than effective_date" do
    before do 
      @user_plan.expiration_date = @user_plan.effective_date-1
    end
    it { should_not be_valid }
  end


end
