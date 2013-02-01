# encoding: UTF-8

class AuthenticationsController < ApplicationController
  def index
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



=begin
    if authentication  
      flash[:notice] = "Signed in successfully."
      redirect_to root_url 
      # sign_in_and_redirect(:user, authentication.user)  
    elsif current_user  
      current_user.authentications.create(:provider => omniauth['provider'], :uid => omniauth['uid'])  
      flash[:notice] = "Authentication successful."  
      redirect_to root_url  
    else  
      #raise request.env["omniauth.auth"].to_yaml
      user = User.create
      user.authentications.build(provider: omniauth['provider'], uid: omniauth['uid'])
      user.save!  
      flash[:notice] = "Signed in successfully."  
      sign_in(user)
      redirect_to root_url  
    end
    
#    if signed_in?
#      raise request.env["omniauth.auth"].to_yaml
#    else
#      raise "pacho"
#    end
=end
  end


  def destroy
  end
end
