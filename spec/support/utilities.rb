include ApplicationHelper


def sign_in_test
  visit root_path
  click_link "Entrar con Facebook"
end


def current_auth
   @current_auth ||= Authentication.find_by_provider_and_uid(OmniAuth.config.mock_auth[:facebook]["provider"], OmniAuth.config.mock_auth[:facebook]["uid"])
end
