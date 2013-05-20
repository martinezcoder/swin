# encoding: UTF-8

require "spec_helper"

# pruebas extraidas de "https://github.com/remi/testing-omniauth"   OMG!!!!

def logged_in?
  page.has_selector? "a", text: "Cerrar sesión"
end

def login_with(provider, mock_options = nil)
  if mock_options == :invalid_credentials
    OmniAuth.config.mock_auth[provider] = :invalid_credentials
  elsif mock_options
    OmniAuth.config.add_mock provider, mock_options
  end

  visit "/auth/#{provider}"
end



feature "Using Login Buttons" do

  before do
    visit root_path
  end

  it { logged_in?.should == false }

  describe "using Facebook" do
    before do
#      puts OmniAuth.config.mock_auth[:facebook]
      clicar_entrar
    end
    
    it { logged_in?.should == false }
    
    it { page.should have_content "Confirmación de registro" }


    describe "submitting to confirm" do
        before { click_button "Confirmar" }
        it { page.should have_content "No ha aceptado las condiciones de registro" }
    end


    describe "submitting to the create action" do
      before { post users_path }
      specify { response.should redirect_to(new_user_path) }
    end

  end

end


feature "Logging in directly" do

  before do
    visit root_path
    logged_in?.should == false
  end

  scenario "using Facebook" do
    login_with :facebook, uid: "fb-12345", info: { name: "Bob Smith" }

    page.should have_content "Logged into facebook as Bob Smith (fb-12345)"
    logged_in?.should == true
  end
end
