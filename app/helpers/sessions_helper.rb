# encoding: UTF-8

module SessionsHelper

  def sign_in(user)
    cookies.permanent[:remember_token] = user.remember_token
    session[:provider] = { FACEBOOK => { status: OFF }, TWITTER => { status: OFF }, YOUTUBE  => { status: OFF } }
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
    session.delete(:active_tab)
    session.delete(:provider)
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

  # Authorization functions (before_filter) 
  
  def signed_in_user
    unless signed_in?
      store_location
      redirect_to root_path, notice: "No ha iniciado la sesión. Por favor, inicie la sesión." 
    end
  end


  # omniauth and socialnetworks authentication functions

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
  
  def create_new_auth
    newauth = current_user.authentications.new
    newauth.provider = omniauth['provider']
    newauth.uid = omniauth['uid']
    newauth.token = omniauth['credentials']['token']
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
    # actualizamos token si éste ha cambiado
    if !(current_auth.token == omniauth['credentials']['token'])
      current_auth.token = omniauth['credentials']['token']
      current_auth.save
    end
    # poner provider a ON si no está ya puesto
    session[:provider][omniauth['provider']][:status] = ON
    flash[:notice] = "#{omniauth['provider']} ON" unless !msg
  end

  def turn_off_auth(provider)
    session[:provider][provider][:status] = OFF    
  end

  def is_active?(provider)
    session[:provider][provider][:status] == ON
  end

  def get_token provider
    current_user.authentications.find_by_provider(provider).token
  end


  # activate lists
  def set_active_list(id)
    list = current_user.facebook_lists.find(id)
    cookies.permanent[:fb_list] = id if current_user.facebook_lists.include?(list)
  end

  def get_active_list
    begin
      current_user.facebook_lists.find_by_id(cookies[:fb_list])
    rescue
      nil
    end    
  end

  def get_active_list_page
    begin
      list = get_active_list
      page = Page.find(list.page_id)
      page
    rescue
      nil
    end
  end

  
end
