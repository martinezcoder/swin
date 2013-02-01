module SessionsHelper

  def sign_in(user)
    cookies[:remember_token] = user.remember_token
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?  # esto llamará a la función "def curren_user" que buscará en BD el token del usuario
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= User.find_by_remember_token(cookies[:remember_token])
  end

  def current_user?(user)
    user == current_user
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  def redirect_back_or(default)
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location
    session[:return_to] = request.url
  end


  # Authorization functions 
  
  def signed_in_user
    unless signed_in?
      store_location
      redirect_to signin_url, notice: "Por favor, inicie la sesion" 
    end
  end


end
