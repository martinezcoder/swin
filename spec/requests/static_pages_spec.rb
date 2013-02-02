# encoding: UTF-8

require 'spec_helper'

describe "StaticPages" do

  subject { page }

  let(:base_title) { "SocialWin Analytics" }
   
  describe "Home page" do

    before { visit root_path }

    it "should have the h1 'SocialWin Analytics'" do
      should have_selector('h1', :text => "#{base_title}")
    end

    it "should have the title 'SocialWin Analytics'" do
      should have_selector('title', :text => full_title('') )
    end


    it "should have the right links on the layout" do
      visit root_path
      click_link "Ayuda"
      should have_selector 'title', text: full_title('Ayuda')
      click_link "Home"
#      click_link "Entrar con Facebook"
#      click_link "Entrar con Twitter"
    end

  end



  describe "Help page" do

    before { visit help_path }

    it "should have the h1 'Ayuda'" do
      should have_selector('h1', :text => 'Ayuda')
    end

    it "should have the title 'Ayuda'" do
      should have_selector('title', :text => full_title('Ayuda'))
    end

  end



  describe "About page" do

    before { visit about_path }

    it "should have the h1 'Quién somos'" do
      should have_selector('h1', :text => 'Quién somos')
    end

    it "should have the title 'Quién somos'" do
      should have_selector('title', :text => full_title('Quién somos'))
    end

  end


end
