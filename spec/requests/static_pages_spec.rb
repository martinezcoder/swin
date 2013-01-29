# encoding: UTF-8

require 'spec_helper'

describe "StaticPages" do


  describe "Home page" do

    it "should have the h1 'SocialWin Analytics'" do
      visit '/static_pages/home'
      page.should have_selector('h1', :text => 'SocialWin Analytics')
    end

    it "should have the title 'Home'" do
      visit '/static_pages/home'
      page.should have_selector('title',
                        :text => "SocialWin Analytics | Home")
    end

  end



  describe "Help page" do

    it "should have the h1 'Ayuda'" do
      visit '/static_pages/help'
      page.should have_selector('h1', :text => 'Ayuda')
    end

    it "should have the title 'Help'" do
      visit '/static_pages/help'
      page.should have_selector('title',
                        :text => "SocialWin Analytics | Ayuda")
    end

  end



  describe "About page" do

    it "should have the h1 'Quién somos'" do
      visit '/static_pages/about'
      page.should have_selector('h1', :text => 'Quién somos')
    end

    it "should have the title 'About'" do
      visit '/static_pages/about'
      page.should have_selector('title',
                        :text => "SocialWin Analytics | Quién somos")
    end

  end


end
