# encoding: UTF-8

require 'spec_helper'

describe "User pages" do

  subject { page }


  describe "edit profile" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit edit_user_path(user) }

    describe "page" do
      it { should have_selector('h1', text: 'Confirma tus datos')}
      it { should have_selector 'title' , text: full_title('Edición de perfil') }
# FALTA: link para cambiar la foto de perfil. Nos dejará utilizar la foto de twitter, de facebook o de la página de facebook que utilizamos
    end

    describe "with invalid information" do
      before do 
        fill_in "Nombre",    with: "a" * 51
        click_button "Confirmar"
      end
      it { should have_content('error') }
    end

    describe "without checking policy" do
      it { should error }
    end

    describe "if user cancel registration" do
      it { should destroy user }
    end
    
  end

  describe "profile page" do
    let(:user) { FactoryGirl.create(:user) }
    before { visit user_path(user) }

    it { should have_selector('h1',    text: user.name) }
    it { should have_selector('title', text: user.name) }
  end

end