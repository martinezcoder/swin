# encoding: UTF-8

module AuthenticationsHelper

  def omniauth
    @omniauth
  end

  def current_auth
    @current_auth ||= Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
  end

  def auth_exist?
    !self.current_auth.nil? # this will call to "def current_auth" that will search in DB if the provider exists.
  end

  def same_user?
    current_user?(current_auth.user)
  end

  def signout_or_merge
    flash[:error] = "Usuario incorrecto para esta cuenta. Sesión finalizada."
    sign_out
  end  
  
  def create_new_user
    user = User.create(name: omniauth['info']['name'], 
                       email: omniauth['info']['email'] ||= nil
                       )

    user.save!
    sign_in(user)
  end

  def create_new_auth
    newauth = current_user.authentications.new(provider: omniauth['provider'], uid: omniauth['uid'], token: omniauth['credentials']['token'])
    if newauth.save
      if omniauth['provider'] == FACEBOOK and current_user.email.nil?
        current_user.update_attributes(email: omniauth['info']['email'])
        sign_in current_user
      end
    else
      flash[:error] = "Se ha producido un error"
      sign_out
    end
  end

  def turn_on_auth(msg)
    # poner provider a ON si no está ya puesto
    cookies[omniauth['provider']] = "ON"
    flash[:notice] = "#{omniauth['provider']} ON" unless !msg
  end

  def turn_off_auth(provider)
    cookies[provider] = "OFF"    
  end

end
