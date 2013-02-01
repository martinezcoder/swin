# encoding: UTF-8

class AuthenticationsController < ApplicationController
  before_filter :signed_in_user,  only: [:index, :destroy]
  before_filter :correct_user,    only: [:index, :destroy]

  def index
    @connections = current_user.authentications
  end

  def create

    omniauth = request.env["omniauth.auth"]  
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid']) 

    if signed_in?
      if authentication
        # poner provider a ON si no está ya puesto
        flash[:notice] = "#{omniauth['provider']} ON"  
        redirect_to root_url  
      else
        current_user.authentications.create(:provider => omniauth['provider'], :uid => omniauth['uid'])  
        flash[:notice] = "Nueva conexión de usuario"  
        redirect_to root_url  
      end
    else
      if authentication
        sign_in(authentication.user)
        if omniauth['provider'] == 'twitter'
          flash[:notice] = "Bienvenido #{omniauth['uid']}"
        elsif omniauth['provider'] == 'facebook'
#          raise request.env["omniauth.auth"].to_yaml
          flash[:notice] = "Bienvenido #{omniauth.info.name}"  
        end
        #poner provider a ON
        redirect_to root_url 
      else
        user = User.create
        user.authentications.build(provider: omniauth['provider'], uid: omniauth['uid'])
        user.save!  
        flash[:notice] = "Nuevo usuario"  
        sign_in(user)
        redirect_to root_url          
      end
    end

  end


  def destroy
  end


  private

    def correct_user
      @user = Authentication.find(params[:id]).user
      redirect_to(root_path) unless current_user?(@user)
    end 
    
end
