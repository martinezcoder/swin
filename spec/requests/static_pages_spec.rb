require 'spec_helper'

describe "StaticPages" do

  describe "Home page" do

    it "should have the content 'SocialWin Analytics'" do
      visit '/static_pages/home'
      page.should have_content('SocialWin Analytics')
    end
  end

  describe "Help page" do

    it "should have the content 'Ayuda'" do
      visit '/static_pages/help'
      page.should have_content('Ayuda')
    end
  end

  describe "About page" do

    it "should have the content 'Sobre nosotros'" do
      visit '/static_pages/about'
      page.should have_content('Sobre nosotros')
    end
  end


end
