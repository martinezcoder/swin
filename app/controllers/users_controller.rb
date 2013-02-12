# encoding: UTF-8

class UsersController < ApplicationController
include PagesHelper

  before_filter :signed_in_user
  before_filter :correct_user
  before_filter :approved_user, only: [:show]
  before_filter :not_approved_user, only: [:destroy]


  def show
    @user = User.find(params[:id])

    ftoken = get_token FACEBOOK
    fgraph  = Koala::Facebook::API.new(ftoken)

    @pages = fgraph.fql_query("SELECT page_id, username, type, page_url, name, pic_square, fan_count, talking_about_count from page WHERE page_id in (SELECT page_id from page_admin where uid=me())")
    pages_save_or_update(@pages)

  end
  
  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if !@user.approved_policy
      if @user.update_attributes(params[:user])
        sign_in(@user)
        if current_user.approved_policy
          flash[:info] = "Bienvenido #{@user.name}"
          redirect_to user_path(current_user)
        else
          flash[:info] = 'No ha aceptado las condiciones de registro'
          redirect_to edit_user_path(current_user)
        end
      else
        render 'edit'
      end
    else
      redirect_to user_path(current_user)
    end
    
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:info] = "Registro cancelado."
    redirect_to root_path
  end

  private

    def correct_user
      begin
        @user = User.find(params[:id])
        redirect_to(root_path) unless current_user?(@user)
      rescue
        redirect_to(root_path)
      end
    end

    def not_approved_user
      begin
        @user = User.find(params[:id])
        redirect_to(root_path) unless !@user.approved_policy
      rescue
        redirect_to(root_path)
      end

    end

    def approved_user
      begin
        @user = User.find(params[:id])
        redirect_to(root_path) unless @user.approved_policy
      rescue
        redirect_to(root_path)
      end
    end

    def get_token provider
      current_user.authentications.find_by_provider(provider).token
    end

end
