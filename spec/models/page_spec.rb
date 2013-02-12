require 'spec_helper'

describe Page do

  before { 
          @page = Page.new( 
                    page_id: "349679691794392",
                    name: "SocialWin",
                    page_url: "http://www.facebook.com/pages/SocialWin/349679691794392",
                    pic_square: "http://profile.ak.fbcdn.net/hprofile-ak-snc6/276654_349679691794392_1240268105_q.jpg",
                    type: "CONSULTING/BUSINESS SERVICES",
                    username: "socialwin"
                    )
          }
  
  subject { @page }

  it { should respond_to(:name) }
  it { should respond_to(:page_url) }
  it { should respond_to(:pic_square) }
  it { should respond_to(:type) }
  it { should respond_to(:username) }
  it { should respond_to(:page_id) }
  
  it { should be_valid }


  describe "when page_id is not present" do
    before { @page.page_id = nil }
    it { should_not be_valid }
  end

end
