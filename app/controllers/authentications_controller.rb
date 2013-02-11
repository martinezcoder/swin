# encoding: UTF-8

class AuthenticationsController < ApplicationController
include AuthenticationsHelper

  before_filter :signed_in_user,  only: [:index, :destroy]
  before_filter :correct_user,    only: [:index, :destroy]

  def index
    @connections = current_user.authentications
  end

  def create
    #raise request.env["omniauth.auth"].to_yaml

    @omniauth = request.env["omniauth.auth"]

    if signed_in?
      if auth_exist?
        if same_user?
          turn_on_auth(true)
        else
          # this provider is asigned to other user. Posibility of Merge will be done in next version.
          signout_or_merge
        end
      else
        create_new_auth
        turn_on_auth(true)
      end
      redirect_back_or user_path(current_user)
    else
      if auth_exist?
        sign_in(current_auth.user)
        turn_on_auth(false)
        redirect_back_or user_path(current_user)
      else
        create_new_user
        sign_in(current_auth.user)
        turn_on_auth(false)
        redirect_back_or edit_user_path(current_user)
      end
    end

  end


  private

    def correct_user
      @user = Authentication.find(params[:id]).user
      redirect_to(root_path) unless current_user?(@user)
    end 
    
end
