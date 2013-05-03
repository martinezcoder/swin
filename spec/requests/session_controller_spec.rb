# encoding: UTF-8

require 'spec_helper'

describe "SessionsController" do

  before do
    request["omniauth.auth"] = OmniAuth.config.mock_auth[:facebook]
  end

  it "sets a session variable to the OmniAuth auth hash" do
    request["omniauth.auth"]['uid'].should == '123545'
  end
end
