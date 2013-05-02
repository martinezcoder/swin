require 'spec_helper'

describe ListPageRelationship do

  let(:page) { FactoryGirl.create(:page) }
  let(:user) { FactoryGirl.create(:user) }
  let(:list) { user.facebook_lists.create }


  before do
    @fblist = list.list_page_relationships.build(page_id: page.id)
  end

  subject { @fblist }
  
  it { should be_valid }

  describe "accessible attributes" do
    it "should not allow access to list_id" do
      expect do
        ListPageRelationship.new(list_id: list.id)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end    
  end

  describe "followers methods" do
      it { should respond_to(:list_id) }
      it { should respond_to(:page_id) }
      its(:page) { should == page }
      its(:list) { should == list }
  end

end
