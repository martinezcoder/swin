include ApplicationHelper
include SessionsHelper

def clicar_entrar
  click_link "Entra con Facebook"
end

def sign_in_test
  visit root_path
  click_link "Entra con Facebook"
end


