require 'spec_helper'

describe FacebookList do

  let(:user) { FactoryGirl.create(:user) }
  before do
    @fblist = user.facebook_lists.build(name: "Lorem ipsum", photo_url: "xxx")
  end

  subject { @fblist }

  it { should respond_to(:name) }
  it { should respond_to(:photo_url) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) }
  it { should respond_to(:list_page_relationships) }
  
  its(:user) { should == user }

  it { should be_valid }

  describe "accessible attributes" do
    it "should not allow access to user_id" do
      expect do
        FacebookList.new(user_id: user.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end

  describe "when name is too long" do
    before { @fblist.name = "a" * 51 }
    it { should_not be_valid }
  end

  describe "when user_id is not present" do
    before { @fblist.user_id = nil }
    it { should_not be_valid }
  end

end
