class AuthenticationsController < ApplicationController
  def index
  end

  def create
    raise request.env["omniauth.auth"].to_yaml  
  end

  def destroy
  end
end
