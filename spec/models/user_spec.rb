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

require 'spec_helper'

describe User do

  before { @user = User.new(name: "Example User", email: "user@example.com", terms_of_service: '1') }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:authentications) }  
  it { should respond_to(:pages) }
  it { should respond_to(:user_page_relationships) }
  it { should respond_to(:facebook_lists) }
  it { should respond_to(:user_plan_relationships) }
  
  it { should be_valid }

  describe "should validate acceptance of terms_of_service" do
    it { should validate_acceptance_of(:terms_of_service) }
  end

  describe "when terms_of_service is not accepted" do
    before { @user.terms_of_service = '0' }
    it { should_not be_valid }
  end
  
  describe "when name is not present" do
    before { @user.name = " " }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @user.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when email format is invalid" do
    it "should be invalid" do
      addresses = %w[user@foo,com user_at_foo.org example.user@foo.
                     foo@bar_baz.com foo@bar+baz.com]
      addresses.each do |invalid_address|
        @user.email = invalid_address
        @user.should_not be_valid
      end      
    end
  end

  describe "when email format is valid" do
    it "should be valid" do
      addresses = %w[user@foo.COM A_US-ER@f.b.org frst.lst@foo.jp a+b@baz.cn]
      addresses.each do |valid_address|
        @user.email = valid_address
        @user.should be_valid
      end      
    end
  end

  describe "when email address is already taken" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.save
    end

    it { should_not be_valid }
  end

  describe "when email address is already taken in downcase" do
    before do
      user_with_same_email = @user.dup
      user_with_same_email.email = @user.email.upcase
      user_with_same_email.save
    end
    it { should_not be_valid }
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end


  describe "authentication associations" do

    before { @user.save }
    let!(:face_auth) do 
      FactoryGirl.create(:authentication, user: @user, provider: "facebook", uid: "1")
    end
    let!(:twitt_aut) do
      FactoryGirl.create(:authentication, user: @user, provider: "twitter", uid: "1")
    end

    it "should have both" do
      @user.authentications.should == [face_auth, twitt_aut]
    end
    
    it "should be 2 providers" do
      @user.authentications.count.should == 2
    end


    it "should destroy associated authentications" do
      authentications = @user.authentications.dup
      @user.destroy
      authentications.should_not be_empty
      authentications.each do |auth|
        Authentication.find_by_id(auth.id).should be_nil
      end
    end

  end

  describe "facebook lists associations" do

    before { @user.save }
  
    let!(:old_list) do 
      FactoryGirl.create(:facebook_list, user: @user, name: "first list", created_at: 1.day.ago)
    end
    let!(:new_list) do
      FactoryGirl.create(:facebook_list, user: @user, name: "second list", created_at: 1.hour.ago)
    end

    it "should have the right lists in the right order" do
      @user.facebook_lists.should == [old_list, new_list]
    end

    it "should destroy associated facebook lists" do
      lists = @user.facebook_lists.dup
      @user.destroy
      lists.should_not be_empty
      lists.each do |list|
        FacebookList.find_by_id(list.id).should be_nil
      end
    end

  end

  describe "new plan" do
    let(:plan) { FactoryGirl.create(:plan) }
    before do
      @user.save
      @user.set_plan!(plan, nil)
    end
    
    its(:plans) { should include(plan) }

    it "should increment the number of user plans" do
      expect do
        @user.save
        @user.set_plan!(plan, nil)
      end.to change(@user.plans, :count).by(1)
    end      

    it "should not increment the number of ACTIVE user plans" do
      expect do
        @user.save
        @user.set_plan!(plan, nil)
      end.to change(@user.active_plans, :count).by(0)
    end      

  end
    
  
end
