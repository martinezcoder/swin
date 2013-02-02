# encoding: UTF-8

module AuthenticationsHelper


  def omniauth
    @omniauth
  end

  def current_auth #(omniauth)
    @current_auth ||= Authentication.find_by_provider_and_uid(@omniauth['provider'], @omniauth['uid'])
  end

  def authentication_exist? #(omniauth)
    #!current_auth(omniauth).nil?  # this will call to "def current_auth" that will search in DB if the provider exists.
    !current_auth.nil?
  end


  def create_new_user
    user = User.create(name: omniauth.info.name, email: omniauth.info.email ||= nil)
    user.authentications.build(provider: omniauth.provider, uid: omniauth.uid)
    user.save!  
    signin_and_turn_on_authentication("Nuevo usuario: #{current_auth.user.name}")
  end

  def signin_and_turn_on_authentication(msg)
    sign_in(current_auth.user)
    turn_on_authentication
    flash[:notice] = msg ||= "Bienvenido #{current_auth.user.name}"
  end

  def new_user_authentication
    newauth = current_user.authentications.new(:provider => omniauth.provider, :uid => omniauth.uid)
    if newauth.save  
      flash[:notice] = "Nuevo proveedor asignado al usuario: #{omniauth.provider}"
    else  
      flash[:error] = "Usuario incorrecto para esta cuenta"
    end  
  end

  def turn_on_authentication
    if current_user?(current_auth.user)
      # poner provider a ON si no está ya puesto
      flash[:notice] = "#{omniauth.provider} ON"
    else
      # este provider no está asociado con esta sesión si no con otra...
      # habría que mirar si se puede hacer un merge de sesiones
      # por seguridad casi mejor cerrar la sesión en estos casos.
      flash[:error] = "Usuario incorrecto para esta cuenta"
    end
  end

  def turn_off_authentication    
  end

end
