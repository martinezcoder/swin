# encoding: UTF-8

require 'spec_helper'

describe "AuthenticationPages" do

  subject { page }

  describe "Sign in page" do

    before { visit root_path }

    it { should have_selector('h1', text: 'Bienvenido a SocialWin Analytics') }
    it { should have_selector('title', text: 'SocialWin Analytics') }

    it { should have_link('Home', href: root_path) }
    it { should have_link('Ayuda',    href: help_path) }


    describe "Sign in and sign out" do

      describe "policy confirmation page" do

        before do
          sign_in_test
        end
  
        it { should_not have_link('Perfil', href: user_path(current_auth.user)) }
        it { should_not have_link('Ajustes', href: edit_user_path(current_auth.user)) } 
        it { should_not have_link('Cerrar sesión', href: signout_path) }
  
        describe "User confirms with approved policy" do
          before do
            current_auth.user.approved_policy = true
            current_auth.user.save
            sign_in_test
          end
          
          it { should have_link('Perfil', href: user_path(current_auth.user)) }
          it { should have_link('Ajustes', href: edit_user_path(current_auth.user)) } 
          it { should have_link('Cerrar sesión', href: signout_path) }

          describe "User signs out. " do
            before do
              click_link "Cerrar sesión"
            end
            it { should have_link('Facebook') }
            it { should have_link('Twitter') }
          end

        end

        describe "user confirms with invalid fields " do

          describe "with invalid information" do
            before do 
              fill_in "Nombre",    with: "a" * 51
              click_button "Confirmar"
            end
            it { should have_content('error') }
          end

          describe "without checking policy" do
            before { click_button "Confirmar" }
            it { should have_selector('div.alert.alert-error') }
          end

          describe "if user cancel registration" do
            it { should destroy user }
          end
          
        end

      end

    end


    describe "new user creation creates a new User and Authentication into database" do
      it "should create a new user" do
        expect do
           sign_in_test
           current_auth.user.save! 
        end.to change(User, :count).by(1)
      end
      it "should create a new provider" do
        expect do
           sign_in_test
           current_auth.save!
        end.to change(Authentication, :count).by(1)
      end
    end


    describe "Sign in with existing user it wont change the database User and Authentication count " do
      let(:user) { FactoryGirl.create(:user) }     
      before do
        @provider = user.authentications.build(provider: OmniAuth.config.mock_auth[:facebook]["provider"], uid: OmniAuth.config.mock_auth[:facebook]["uid"])
        @provider.save!
      end
      it "should not create a new user" do
        expect do
          sign_in_test
          current_auth.user.save
        end.not_to change(User, :count)
      end
      it "should not create a new authentication" do
        expect do 
          sign_in_test
          current_auth.save 
        end.not_to change(Authentication, :count)
      end
    end



  end

end
