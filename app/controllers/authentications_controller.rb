# encoding: UTF-8

class AuthenticationsController < ApplicationController
  before_filter :signed_in_user,  only: [:index, :destroy]
  before_filter :correct_user,    only: [:index, :destroy]

  def index
    @connections = current_user.authentications
  end

  def create
    #raise request.env["omniauth.auth"].to_yaml

    @omniauth = request.env["omniauth.auth"]

    if signed_in?
      if authentication_exist?
        turn_on_authentication(true)
      else
        new_user_authentication_provider
      end
    else
      create_new_user unless authentication_exist? 
      signin_and_turn_on_authentication
    end
    redirect_back_or edit_user_path(current_user)

  end

  private

    def correct_user
      @user = Authentication.find(params[:id]).user
      redirect_to(root_path) unless current_user?(@user)
    end 
    
end
