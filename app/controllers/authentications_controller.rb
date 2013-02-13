# encoding: UTF-8

class AuthenticationsController < ApplicationController
include AuthenticationsHelper

  before_filter :signed_in_user,  only: [:index, :destroy]
  before_filter :correct_user,    only: [:index, :destroy]

  def index
    @connections = current_user.authentications
  end

  def create
    
    @omniauth = request.env["omniauth.auth"]
    if signed_in?
      if auth_exist?
        if same_user?
          turn_on_auth(true)
          redirect_back_or user_path(current_user)
        else
          # this provider is asigned to other user. Posibility of Merge will be done in next version.
          signout_or_merge
          redirect_to root_path
        end
      else
        create_new_auth
        turn_on_auth(true)
        redirect_back_or user_path(current_user)
      end
    else
      if auth_exist?
        sign_in(current_auth.user)
        turn_on_auth(false)
        redirect_back_or user_path(current_user)
      else
        @user = User.new(name: omniauth['info']['name'], email: omniauth['info']['email'] ||= nil)
        session[:omniauth] = @omniauth
      end
    end

  end


  private

    def correct_user
      @user = Authentication.find(params[:id]).user
      redirect_to(root_path) unless current_user?(@user)
    end 
    
end
