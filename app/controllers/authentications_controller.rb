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
        if authentication.user == current_user
          # poner provider a ON si no está ya puesto
          flash[:notice] = "#{omniauth['provider']} ON"
        else
          flash[:error] = "Usuario incorrecto para esta cuenta"
        end  
        redirect_to root_path 
      else
        newauth = current_user.authentications.new(:provider => omniauth['provider'], :uid => omniauth['uid'])
        if newauth.save  
          flash[:notice] = "Nueva conexión de usuario"
        else  
          flash[:error] = "Usuario incorrecto para esta cuenta"
        end  
        redirect_to root_path
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
        redirect_to root_path 
      else
        user = User.create
        user.authentications.build(provider: omniauth['provider'], uid: omniauth['uid'])
        user.save!  
        flash[:notice] = "Nuevo usuario"  
        sign_in(user)
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
