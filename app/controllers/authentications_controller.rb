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
      if authentication_exist?
        turn_on_authentication
        redirect_to root_path
      else
        new_user_authentication
        redirect_to root_path
      end
    else
      if authentication_exist?
        # new existing user signing in through his provider
        signin_and_turn_on_authentication(nil)
        redirect_to root_path 
      else
        # new user with new provider
        create_new_user
        redirect_to root_path
      end
    end

  end


  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Conexión eliminada."
    redirect_to root_path
  end


  private

    def correct_user
      @user = Authentication.find(params[:id]).user
      redirect_to(root_path) unless current_user?(@user)
    end 
    
end
