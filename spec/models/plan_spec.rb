# == Schema Information
#
# Table name: plans
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  num_competitors :integer
#  num_lists       :integer
#  price           :float
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

require 'spec_helper'

describe Plan do

  before {
    @plan = Plan.new
    @plan.name = "test"
    @plan.num_competitors = 10
    @plan.num_lists = 10
    @plan.price = 0
  }

  subject { @plan }

  it { should respond_to(:name) }
  it { should respond_to(:num_competitors) }
  it { should respond_to(:num_lists) }
  it { should respond_to(:price) }


  describe "when name is not present" do
    before { @plan.name = nil }
    it { should_not be_valid }
  end

  describe "when num_competitors is not present" do
    before { @plan.num_competitors = nil }
    it { should_not be_valid }
  end
  
  describe "when num_lists is not present" do
    before { @plan.num_lists = nil }
    it { should_not be_valid }
  end

  describe "when price is not present" do
    before { @plan.price = nil }
    it { should_not be_valid }
  end

  describe "when name is too long" do
    before { @plan.name = "a" * 21 }
    it { should_not be_valid }
  end

  describe "when num_competitors is not number" do
    before { @plan.num_competitors = "a" }
    it { should_not be_valid }
  end

  describe "when num_lists is not number" do
    before { @plan.num_lists = "a" }
    it { should_not be_valid }
  end  

  describe "when price is not number" do
    before { @plan.price = "a" }
    it { should_not be_valid }
  end  

  describe "when name is already taken" do
    before do
      plan_with_same_name = @plan.dup
      plan_with_same_name.save
    end

    it { should_not be_valid }
  end
  

end
