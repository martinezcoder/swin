# encoding: UTF-8

class UsersController < ApplicationController
  include PagesHelper


  def new
    omniauth = session[:omniauth]
    @user = User.new(name: omniauth['info']['name'], email: omniauth['info']['email'] ||= nil)
  end

  def create
    @user = User.new(params[:user])
    if params[:user]["terms_of_service"] == '1'  
      if @user.save!
        sign_in @user
        @omniauth = session[:omniauth]
        session.delete(:omniauth)
        create_new_auth
        turn_on_auth(false)
        redirect_to facebook_lists_path
      end
    else
      flash[:info] = 'No ha aceptado las condiciones de registro'
      render "new"
    end
  end

=begin
  before_filter :signed_in_user, only: [:show]
  before_filter :correct_user,  only: [:show]


  def show
    @user = User.find(params[:id])
  end

  private

    def correct_user
      begin
        @user = User.find(params[:id])
        redirect_to user_path(current_user) unless current_user?(@user)
      rescue
        redirect_to user_path(current_user)
      end
    end
=end

end
