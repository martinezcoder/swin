# == Schema Information
#
# Table name: authentications
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  provider   :string(255)
#  uid        :string(255)
#  token      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Authentication do

  let(:user) { FactoryGirl.create(:user) }
  before { @provider = user.authentications.build(provider: 'facebook', uid: '123456') }

  subject { @provider }

  it { should respond_to(:provider) }
  it { should respond_to(:uid) }
  it { should respond_to(:token) }

  it { should respond_to(:user_id) }
  it { should respond_to(:user) }

  its(:user) { should == user }

  it { should be_valid }
  
  describe "when provider is not present" do
    before { @provider.provider = " " }
    it { should_not be_valid }
  end

  describe "when uid is not present" do
    before { @provider.uid = " " }
    it { should_not be_valid }
  end

  describe "when provider is not in the inclusion list" do
    before { @provider.provider = "invalid" }
    it { should_not be_valid }
  end

  describe "when uid is too long" do
    before { @provider.uid = "1" * 51 }
    it { should_not be_valid }
  end

  describe "when uid is not a number" do
    before { @provider.uid = "abcdefg" }
    it { should_not be_valid }
  end

  describe "when user_id-provider already exists in db" do
    before do
      @repeat_provider = user.authentications.build(provider: 'facebook', uid: '123456')
      @repeat_provider.save
    end
    
    it {should_not be_valid}
  end

end
