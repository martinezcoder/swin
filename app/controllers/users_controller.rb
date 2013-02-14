# encoding: UTF-8

class UsersController < ApplicationController
  include PagesHelper
  include AuthenticationsHelper

  before_filter :signed_in_user, except: [:create]
  before_filter :correct_user, except: [:create]
  before_filter :is_your_token, only: [:create]

  def create
    @user = User.new(params[:user])
    if params[:user]["terms_of_service"] == '1'  
      if @user.save!
        sign_in @user
        @omniauth = session[:omniauth]
        session.delete(:omniauth)
        create_new_auth
        turn_on_auth(false)
        flash[:info] = "Bienvenido a SocialWin Analytics!"
        redirect_to @user # sería lo mismo poner:  render 'show'
      end
    else
      flash[:info] = 'No ha aceptado las condiciones de registro'
      render "authentications/create"
    end
  end

  def show
    @user = User.find(params[:id])

    ftoken = get_token FACEBOOK
    
    begin
      fgraph  = Koala::Facebook::API.new(ftoken)
      @pages = fgraph.fql_query("SELECT page_id, username, type, page_url, name, pic_square, fan_count, talking_about_count from page WHERE page_id in (SELECT page_id from page_admin where uid=me())")
    rescue
      flash[:info] = "Facebook no responde. Por favor, inténtelo más tarde."
      sign_out
      redirect_to root_path
    end
    
    pages_create_or_update(@pages)

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

    def get_token provider
      current_user.authentications.find_by_provider(provider).token
    end

    def is_your_token
      begin
        omniauth = session[:omniauth]
        fgraph  = Koala::Facebook::API.new(omniauth.credentials.token)
        fuid = fgraph.get_object("me")
        redirect_to(root_path) unless fuid["id"] == omniauth.uid
      rescue
        flash[:info] = "Facebook no parece responder. Por favor, inténtelo más tarde."
        redirect_to(root_path) 
      end  
    end

end
