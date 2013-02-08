# encoding: UTF-8

require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "confirmation page" do
    before do
      sign_in_test
      visit edit_user_path(current_auth.user)
    end

    it { should have_selector('h1',    text: 'Confirmación de registro') }
    it { should have_selector('title', text: 'Confirmación de registro') }
  end

end