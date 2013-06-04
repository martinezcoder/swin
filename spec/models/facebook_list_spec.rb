require 'spec_helper'

describe FacebookList do

  let(:user) { FactoryGirl.create(:user) }
  before do
    @fblist = user.facebook_lists.build(name: "Lorem ipsum", photo_url: "xxx", page_id: "000000")
  end

  subject { @fblist }

  it { should respond_to(:name) }
  it { should respond_to(:photo_url) }
  it { should respond_to(:user_id) }
  it { should respond_to(:page_id) }

  it { should respond_to(:user) }
  it { should respond_to(:list_page_relationships) }
  it { should respond_to(:pages) }
  it { should respond_to(:added?) }
  it { should respond_to(:add!) }
  
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

  describe "adding" do
    let(:page) { FactoryGirl.create(:page) }
    before do
      @fblist.save
      @fblist.add!(page)
    end
    it { should be_added(page) }

    its(:pages) { should include(page) }

    describe "and remove" do
      before { @fblist.remove!(page) }

      it { should_not be_added(page) }
      its(:pages) { should_not include(page) }
    end
  end

  describe "list not including pages if not in this list but in other list" do
    let(:page) { FactoryGirl.create(:page) }
    before do
      @fblist2 = user.facebook_lists.build(name: "list 2", photo_url: "xxx", page_id: "000000")
      @fblist2.save
      @fblist2.add!(page)
    end
    it { should_not be_added(page) }
    its(:pages) { should_not include(page) }    
  end

end
