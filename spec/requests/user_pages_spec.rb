# encoding: UTF-8

require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "profile page" do
    before do
      sign_in_test
      visit user_path(current_auth.user)
    end

    it { should have_selector('h1',    text: current_auth.user.name) }
    it { should have_selector('title', text: current_auth.user.name) }
  end

end