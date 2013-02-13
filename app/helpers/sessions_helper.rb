# encoding: UTF-8

module SessionsHelper

  def sign_in(user)
    cookies[:remember_token] = user.remember_token
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?  # this will call to "def current_user" that will search in DB the token == cookies(token)
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

  def get_auth(provider)
    current_user.authentications.find_by_provider(provider)
  end

  # Authorization functions 
  
  def signed_in_user
    unless signed_in?
      store_location
      redirect_to root_path, notice: "No ha iniciado la sesión. Por favor, inicie la sesión." 
    end
  end

end
